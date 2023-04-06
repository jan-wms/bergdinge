import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';
import '../../custom_widgets/select_sports.dart';
import '../../custom_widgets/show_custom_modal.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanEdit extends StatefulWidget {
  const PackingPlanEdit({Key? key}) : super(key: key);

  @override
  State<PackingPlanEdit> createState() => _PackingPlanEditState();
}

class _PackingPlanEditState extends State<PackingPlanEdit> {
  final TextEditingController _controllerName = TextEditingController();
  List<String> sports = <String>[];
  List<PackingPlanItem> items = <PackingPlanItem>[];

  void add() async {
    PackingPlan p =
    PackingPlan(name: _controllerName.text, sports: sports, items: items);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .add(p.toMap());
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
            const Text('Packliste erstellen'),
            ElevatedButton(
                onPressed: () => add(), child: const Text('Erstellen')),
          ],
        ),
        TextField(
          controller: _controllerName,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        ListTile(
          title: Text(sports.isNotEmpty ? sports.toString() : 'Sportart'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            final List<String> s = await selectSports(context, sports);
            setState(() {
              sports = s;
            });
          },
        ),
        ElevatedButton(
            onPressed: () async {
              final List<PackingPlanItem> i =
              await selectEquipment(context, items);
              setState(() {
                items = i;
              });
            },
            child: const Text('Add item')),
        Expanded(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  for (var item in items)
                    ListTile(
                      title:
                      Text((item.equipment.brand ?? '') + item.equipment.name),
                      subtitle: Text(item.equipment.size ?? 'no size'),
                    ),
                ])),
      ],
    );
  }
}

Future<List<PackingPlanItem>> selectEquipment(BuildContext context,
    List<PackingPlanItem> selected) async {
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

class SelectEquipment extends StatefulWidget {
  final List<PackingPlanItem> selected;

  const SelectEquipment({Key? key, required this.selected}) : super(key: key);

  @override
  State<SelectEquipment> createState() => _SelectEquipmentState();
}

class _SelectEquipmentState extends State<SelectEquipment> {
  late List<PackingPlanItem> selected = widget.selected;
  final Future<QuerySnapshot<Equipment>> getEquipmentData =
  FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .collection('equipment')
      .withConverter(
    fromFirestore: Equipment.fromFirestore,
    toFirestore: (Equipment e, _) => e.toMap(),
  )
      .get();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ausrüstung'),
        const TextField(),
        Expanded(
          child: FutureBuilder(
              future: getEquipmentData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }
                return ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                    Equipment e = document.data() as Equipment;
                    return ListTile(
                      title: Text((e.brand ?? '') + e.name),
                      subtitle: Text(e.sports.toString()),
                      trailing: selected.where((element) => element.equipment == e).isNotEmpty
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        if (selected.where((element) => element.equipment == e).isNotEmpty) {
                          setState(() {
                            selected.removeWhere((element) =>
                            element.equipment == e);
                          });
                        } else {
                          setState(() {
                            selected.add(PackingPlanItem(equipment: e,
                                place: Data.places['backpack']!,
                                count: 1));
                          });
                        }
                      },
                    );
                  })
                      .toList()
                      .cast(),
                );
              }),
        ),
      ],
    );
  }
}
