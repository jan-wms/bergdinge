import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';

enum Place {
  body, backpack,
}

class PackingPlan {
  final String name;
  final Map<Equipment, Place> items;
  final List<String> sports;

  PackingPlan({
    required this.name,
    required this.items,
    required this.sports,
  });

  factory PackingPlan.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      items: Map.from(data?['items']),
      sports: List.from(data?['sports']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "items": items,
      "sports": sports,
    };
  }
}