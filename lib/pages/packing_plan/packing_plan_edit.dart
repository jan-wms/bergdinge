import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:equipment_app/validators/packing_plan_validator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/select_sports.dart';
import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanEdit extends StatefulWidget {
  final PackingPlan? packingPlan;

  const PackingPlanEdit({Key? key, this.packingPlan}) : super(key: key);

  @override
  State<PackingPlanEdit> createState() => _PackingPlanEditState();
}

class _PackingPlanEditState extends State<PackingPlanEdit> {
  final _formKey = GlobalKey<FormState>();
  final _formKeySports = GlobalKey<FormFieldState>();
  final _formKeyItems = GlobalKey<FormFieldState>();

  late final TextEditingController _controllerName =
      TextEditingController(text: widget.packingPlan?.name ?? '');

  void edit() async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .doc(widget.packingPlan?.id);

    PackingPlan p = PackingPlan(
      id: ref.id,
      name: _controllerName.text,
      items: _formKeyItems.currentState!.value,
      sports: _formKeySports.currentState!.value,
    );

    await ref.set(p.toMap()).then((value) => context.pop());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
            Text(
                'Packliste ${widget.packingPlan != null ? 'bearbeiten' : 'erstellen'}'),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) edit();
                },
                child: Text(
                    widget.packingPlan != null ? 'Bearbeiten' : 'Erstellen')),
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
                builder: (state) => ListTile(
                  title: Text(state.value!.isNotEmpty
                      ? state.value!.toString()
                      : 'Sportart'),
                  subtitle: Text(state.errorText ?? 'Kein Fehler'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () async {
                    final List<String> s =
                        await selectSports(context, state.value!);
                    setState(() {
                      state.setValue(s);
                    });
                  },
                ),
              ),
              FormField<List<PackingPlanItem>>(
                key: _formKeyItems,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => PackingPlanValidator.items(value),
                initialValue: widget.packingPlan?.items ?? <PackingPlanItem>[],
                builder: (state) => ListTile(
                  onTap: () async {
                    final List<PackingPlanItem> i =
                        await selectEquipment(context, state.value!);
                    setState(() {
                      state.setValue(i);
                    });
                  },
                  trailing: const Icon(Icons.chevron_right_outlined),
                  title: const Text('Add item'),
                  subtitle: Text(state.errorText ?? state.value.toString()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<List<PackingPlanItem>> selectEquipment(
    BuildContext context, List<PackingPlanItem> selected) async {
  final GlobalKey<_SelectEquipmentState> k = GlobalKey();
  final SelectEquipment selectEquipment = SelectEquipment(
    key: k,
    selected: selected,
  );
  await CustomDialog.showCustomModal(
    context,
    selectEquipment,
    null,
    TextButton(
      child: const Text('Close'),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
  return k.currentState!.selected;
}

class SelectEquipment extends ConsumerStatefulWidget {
  final List<PackingPlanItem> selected;

  const SelectEquipment({Key? key, required this.selected}) : super(key: key);

  @override
  ConsumerState<SelectEquipment> createState() => _SelectEquipmentState();
}

class _SelectEquipmentState extends ConsumerState<SelectEquipment> {
  late List<PackingPlanItem> selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ausrüstung'),
        const TextField(),
        Expanded(
          child: ref.watch(equipmentStreamProvider).when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) => ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final equipment = data[index];
                      return ListTile(
                        title: Text((equipment.brand ?? '') + equipment.name),
                        subtitle: Text(equipment.sports.toString()),
                        trailing: selected
                                .where((element) =>
                                    element.equipmentId == equipment.id)
                                .isNotEmpty
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          if (selected
                              .where((element) =>
                                  element.equipmentId == equipment.id)
                              .isNotEmpty) {
                            setState(() {
                              selected.removeWhere((element) =>
                                  element.equipmentId == equipment.id);
                            });
                          } else {
                            setState(() {
                              selected.add(PackingPlanItem(
                                  equipmentId: equipment.id, count: 1));
                            });
                          }
                        },
                      );
                    },
                  )),
        ),
      ],
    );
  }
}
