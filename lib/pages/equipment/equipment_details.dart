import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../firebase/firebase_auth.dart';

class EquipmentDetails extends StatelessWidget {
  final Equipment equipment;

  const EquipmentDetails({Key? key, required this.equipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(equipment.brand ?? 'no brand'),
        Text(equipment.name),
        Text(equipment.sports.toString()),
        Text(equipment.status.toString()),
        Text(equipment.count.toString()),
        Text(equipment.price.toString()),
        ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(Auth().user?.uid)
                  .collection('equipment')
                  .doc(equipment.id).delete();
            },
            child: const Text('delete')),
        ElevatedButton(
            onPressed: () {
              context.go('/equipment/edit', extra: equipment);
            },
            child: const Text('edit')),
      ],
    );
  }
}
