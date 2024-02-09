import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/validators/packing_plan_validator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_dialog.dart';
import '../../data/data.dart';
import '../../data/design.dart';
import '../../data/providers.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanEdit extends ConsumerStatefulWidget {
  final PackingPlan? packingPlan;

  const PackingPlanEdit({Key? key, this.packingPlan}) : super(key: key);

  @override
  ConsumerState<PackingPlanEdit> createState() => _PackingPlanEditState();
}

class _PackingPlanEditState extends ConsumerState<PackingPlanEdit> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _formKeySports = GlobalKey<FormFieldState>();
  late final TextEditingController _controllerName =
      TextEditingController(text: widget.packingPlan?.name ?? '');

  void edit({required List<PackingPlan>? packingPlanList}) async {
    setState(() {
      isLoading = true;
    });

    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .doc(widget.packingPlan?.id);

    PackingPlan p = PackingPlan(
      id: ref.id,
      name: _controllerName.text,
      sports: _formKeySports.currentState!.value,
      createdAt: widget.packingPlan?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      notes: widget.packingPlan?.notes,
      locations: ['Anzug', 'Rucksack'],
    );

    bool continueEdit = true;
    final int? duplicate = packingPlanList?.indexWhere((element) =>
        element.name.toLowerCase() == p.name.toLowerCase() &&
        element.id != p.id);
    if (duplicate != null && duplicate != -1) {
      await CustomDialog.showCustomConfirmationDialog(
        type: ConfirmType.confirmContinue,
              context: context,
              description:
                  'Es existiert bereits eine Packliste mit dem Namen "${packingPlanList!.elementAt(duplicate).name}". Trotzdem fortfahren?')
          .then((value) {
        if (!value) {
          continueEdit = false;
          setState(() {
            isLoading = false;
          });
        }
      });
    }

    if (continueEdit) {
      await ref.set(p.toMap()).then((value) => context.pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            'Packliste ${widget.packingPlan == null ? 'erstellen' : 'bearbeiten'}'),
        actions: [
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate() && !isLoading) {
                edit(
                    packingPlanList: ref.read(packingPlanStreamProvider).value);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Design.colors[1],
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
            child: SizedBox(
              width: 30,
              height: 30,
              child: isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white54,
              )
                  : const Icon(Icons.check_rounded),
            )

          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => PackingPlanValidator.name(value),
                      controller: _controllerName,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                  ),
                  FormField<List<String>>(
                    validator: (value) => PackingPlanValidator.sports(value),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKeySports,
                    initialValue: widget.packingPlan?.sports ?? <String>[],
                    builder: (state) => Column(
                      children: [
                        Wrap(spacing: 5.0,
                            alignment: WrapAlignment.center,
                            children: [
                          for (var sport in Data.sports)
                            FilterChip(
                              showCheckmark: false,
                              label: Text(sport),
                              selected: state.value?.contains(sport) ?? false,
                              onSelected: (bool value) {
                                var oldList = state.value!.toList();
                                if (value) {
                                  if (!state.value!.contains(sport)) {
                                    oldList.add(sport);
                                  }
                                } else {
                                  oldList.removeWhere((String s) {
                                    return s == sport;
                                  });
                                }
                                state.didChange(oldList);
                              },
                            )
                        ]),
                        Visibility(
                          visible: state.errorText == null ? false : true,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              state.errorText ?? 'Kein Fehler',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
