import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';

class PackingPlan {
  final String name;
  final List<PackingPlanItem>? items;
  final List<String> sports;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  PackingPlan({
    required this.name,
    this.items,
    required this.sports,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory PackingPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      id: data?['id'],
      items: data?['items'] != null ? List<PackingPlanItem>.from(List.from(data?['items']).map((e) => PackingPlanItem.fromMap(e))) : null,
      sports: List.from(data?['sports']),
      createdAt: DateTime.parse(data?['createdAt']),
      updatedAt: DateTime.parse(data?['updatedAt']),
      notes: data?['notes'],
    );
  }

  factory PackingPlan.fromMap(
      Map<String, dynamic> data
      ) {
    return PackingPlan(
      name: data['name'],
      id: data['id'],
      items: data['items'] != null ? List.from(
          List.from(data['items']).map((e) => PackingPlanItem.fromMap(e))) : null,
      sports: List.from(data['sports']),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      if (items != null) "items": items?.map((e) => e.toMap()),
      "sports": sports,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      if(notes != null) "notes": notes,
    };
  }
}
