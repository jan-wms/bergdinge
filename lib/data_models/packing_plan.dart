import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlan {
  final String? name;
  final List<PackingPlan>? items;
  final List<String>? sports;
  final String? id;
  final String? equipmentId;
  final int equipmentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PackingPlan({
    this.name,
    this.items,
    this.sports,
    this.id,
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
      items: data?['items'] != null ? List<PackingPlan>.from(List.from(data?['items']).map((e) => PackingPlan.fromMap(e))) : null,
      sports: List.from(data?['sports']),
      equipmentId: data?['equipmentId'],
      equipmentCount: (data?['equipmentCount'] as num).toInt(),
      createdAt: DateTime.tryParse(data?['createdAt']),
      updatedAt: DateTime.tryParse(data?['updatedAt']),
    );
  }

  factory PackingPlan.fromMap(
      Map<String, dynamic> data
      ) {
    return PackingPlan(
      name: data['name'],
      id: data['id'],
      items: data['items'] != null ? List.from(
          List.from(data['items']).map((e) => PackingPlan.fromMap(e))) : null,
     sports: data['sports'] != null ? List.from(data['sports']) : null,
      equipmentId: data['equipmentId'],
      equipmentCount: (data['equipmentCount'] as num).toInt(),
      createdAt:data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null,
        updatedAt:data['updatedAt'] != null ? DateTime.tryParse(data['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) "name": name,
      if (id != null) "id": id,
      if (items != null) "items": items?.map((e) => e.toMap()),
      if (sports != null) "sports": sports,
      if (equipmentId != null) "equipmentId": equipmentId,
      if (equipmentCount != null) "equipmentCount": equipmentCount,
      if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
    };
  }
}
