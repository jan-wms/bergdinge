import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';

class PackingPlan {
  final String name;
  final double weight;
  final List<Equipment> items;

  PackingPlan({
    required this.name,
    required this.weight,
    required this.items,
  });

  factory PackingPlan.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      weight: data?['weight'],
      items: List.from(data?['items']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "weight": weight,
      "items": items,
    };
  }
}