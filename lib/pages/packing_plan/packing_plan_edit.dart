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
    return SafeArea(
      child: Container(
        constraints: (MediaQuery.of(context).size.width > Design.breakpoint1)
            ? const BoxConstraints(
                maxWidth: 600,
                maxHeight: 600,
              )
            : null,
        padding: (MediaQuery.of(context).size.width > Design.breakpoint1)
            ? const EdgeInsets.all(40.0)
            : Design.pagePadding.copyWith(bottom: 40.0, top: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Packliste',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, top: 30.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => PackingPlanValidator.name(value),
                  controller: _controllerName,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: FormField<List<String>>(
                      validator: (value) => PackingPlanValidator.sports(value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKeySports,
                      initialValue: widget.packingPlan?.sports ?? <String>[],
                      builder: (state) => Column(
                        children: [
                          Wrap(
                              runSpacing: 5.0,
                              spacing: 5.0,
                              alignment: WrapAlignment.center,
                              children: [
                                for (var sport in Data.sports)
                                  FilterChip(
                                    showCheckmark: false,
                                    label: Text(sport),
                                    selected:
                                        state.value?.contains(sport) ?? false,
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
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 400.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () => context.pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                        ),
                        child: const Text(
                          'Abbrechen',
                          style: TextStyle(fontSize: 17),
                        )),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          foregroundColor: Colors.white,
                          backgroundColor: Design.colors[1],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && !isLoading) {
                          edit(
                              packingPlanList:
                                  ref.read(packingPlanStreamProvider).value);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 105,
                        child: isLoading
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  color: Colors.white54,
                                ),
                              )
                            : Text(
                                widget.packingPlan == null
                                    ? 'Hinzufügen'
                                    : 'Bearbeiten',
                                style: const TextStyle(fontSize: 17),
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
    );
  }
}
