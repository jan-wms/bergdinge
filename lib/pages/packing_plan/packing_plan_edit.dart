import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/show_custom_modal.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/equipment.dart';
import '../../custom_widgets/select_sports.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanEdit extends StatefulWidget {
  const PackingPlanEdit({Key? key}) : super(key: key);

  @override
  State<PackingPlanEdit> createState() => _PackingPlanEditState();
}

class _PackingPlanEditState extends State<PackingPlanEdit> {
  final TextEditingController _controllerName = TextEditingController();
  List<String> sports = <String>[];
  Map<Equipment, Place> items = {};

  void add() async {
    PackingPlan p = PackingPlan(name: _controllerName.text,
    sports: sports,
    items: items);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .add(p.toFirestore());
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
      ],
    );
  }
}