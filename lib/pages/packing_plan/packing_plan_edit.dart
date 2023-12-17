import 'package:equipment_app/custom_widgets/custom_back_button.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/validators/packing_plan_validator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_dialog.dart';
import '../../data/data.dart';
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomBackButton(),
            const Text('Packliste bearbeiten'),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && !isLoading) {
                    edit(
                        packingPlanList:
                            ref.read(packingPlanStreamProvider).value);
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('edit'))
          ],
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => PackingPlanValidator.name(value),
                controller: _controllerName,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              FormField<List<String>>(
                  validator: (value) => PackingPlanValidator.sports(value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKeySports,
                  initialValue: widget.packingPlan?.sports ?? <String>[],
                  builder: (state) => Column(
                        children: [
                          const Text('Sportart'),
                          Wrap(spacing: 5.0, children: [
                            for (var sport in Data.sports)
                              FilterChip(
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
                          Text(state.errorText ?? 'Kein Fehler'),
                        ],
                      )),
            ],
          ),
        ),
      ],
    );
  }
}
