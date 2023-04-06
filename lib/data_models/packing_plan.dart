import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';

class PackingPlan {
  String name;
  List<PackingPlanItem> items;
  List<String> sports;

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
      items: List.from(List.from(data?['items']).map((e) => PackingPlanItem.fromMap(e))),
      sports: List.from(data?['sports']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "items": items.map((e) => e.toMap()),
      "sports": sports,
    };
  }
}