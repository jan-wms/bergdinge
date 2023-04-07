import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../custom_widgets/select_sports.dart';
import '../../custom_widgets/show_custom_modal.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanEdit extends StatefulWidget {
  final PackingPlan? packingPlan;

  const PackingPlanEdit({Key? key, this.packingPlan}) : super(key: key);

  @override
  State<PackingPlanEdit> createState() => _PackingPlanEditState();
}

class _PackingPlanEditState extends State<PackingPlanEdit> {
  late PackingPlan packingPlan;
  final TextEditingController _controllerName = TextEditingController();

  @override
  void initState() {
    super.initState();
    packingPlan = widget.packingPlan ??
        PackingPlan(
            id: widget.packingPlan?.id ?? 'Fehler',
            name: 'Fehler',
            items: <PackingPlanItem>[],
            sports: <String>[]);

    if (widget.packingPlan != null) _controllerName.text = packingPlan.name;
  }

  void edit() async {
    packingPlan.name = _controllerName.text;

    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .doc(widget.packingPlan?.id);
    packingPlan.id = ref.id;
    await ref.set(packingPlan.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(''),
            Text(
                'Packliste ${widget.packingPlan != null ? 'bearbeiten' : 'erstellen'}'),
            ElevatedButton(
                onPressed: () => edit(),
                child: Text(
                    widget.packingPlan != null ? 'Bearbeiten' : 'Erstellen')),
          ],
        ),
        TextField(
          controller: _controllerName,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        ListTile(
          title: Text(packingPlan.sports.isNotEmpty
              ? packingPlan.sports.toString()
              : 'Sportart'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            final List<String> s =
                await selectSports(context, packingPlan.sports);
            setState(() {
              packingPlan.sports = s;
            });
          },
        ),
        ElevatedButton(
            onPressed: () async {
              final List<PackingPlanItem> i =
                  await selectEquipment(context, packingPlan.items);
              setState(() {
                packingPlan.items = i;
              });
            },
            child: const Text('Add item')),
        Expanded(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
              for (var item in packingPlan.items)
                ListTile(
                  title: Text(item.equipmentId),
                ),
            ])),
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
  await showCustomModal(
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
                                  equipmentId: equipment.id,
                                  place: Data.places['backpack']!,
                                  count: 1));
                            });
                          }
                        },
                      );
                    },
                  )
              ),
        ),
      ],
    );
  }
}
