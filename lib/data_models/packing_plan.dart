import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlan {
  final String? name;
  final List<PackingPlan>? items;
  final List<String>? sports;
  final String id;
  final String? equipmentId;
  final int equipmentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PackingPlan({
    this.name,
    this.items,
    this.sports,
    required this.id,
    this.equipmentId,
    required this.equipmentCount,
    this.createdAt,
    this.updatedAt,
  });

  factory PackingPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      id: data?['id'],
      /*items: List.from(
          List.from(data?['items']).map((e) => PackingPlan.fromFirestore(e))),*/
      sports: List.from(data?['sports']),
      equipmentId: data?['equipmentId'],
      equipmentCount: (data?['equipmentCount'] as num).toInt(),
      createdAt: DateTime.tryParse(data?['createdAt']),
      updatedAt: DateTime.tryParse(data?['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (id != null) "id": id,
      //if (items != null) "items": items?.map((e) => e.toFirestore()),
      if (sports != null) "sports": sports,
      if (equipmentId != null) "equipmentId": equipmentId,
      if (equipmentCount != null) "equipmentCount": equipmentCount,
      if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
    };
  }
}
