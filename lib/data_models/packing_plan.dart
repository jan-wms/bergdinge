import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';

enum Place {
  body, backpack,
}

enum Season {
  spring,
  summer,
  autumn,
  winter,
}

class PackingPlan {
  final String name;
  final double weight;
  final Map<Equipment, Place> items;
  final Season? season;

  PackingPlan({
    required this.name,
    required this.weight,
    required this.items,
    this.season,
  });

  factory PackingPlan.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      weight: data?['weight'],
      items: Map.from(data?['items']),
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