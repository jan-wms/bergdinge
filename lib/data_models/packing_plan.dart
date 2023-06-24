import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlan {
  String? name;
  List<PackingPlan>? items;
  List<String>? sports;
  final String id;
  final String? equipmentId;
  final int equipmentCount;

  PackingPlan({
    required this.name,
    required this.items,
    required this.sports,
    required this.id,
    this.equipmentId,
    required this.equipmentCount,
  });

  factory PackingPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      id: data?['id'],
      items: List.from(
          List.from(data?['items']).map((e) => PackingPlan.fromMap(e))),
      sports: List.from(data?['sports']),
      equipmentId: data?['equipmentId'],
      equipmentCount: (data?['equipmentCount'] as num).toInt(),
    );
  }

  factory PackingPlan.fromMap(
    Map<String, dynamic> map,
  ) {
    return PackingPlan(
      name: map['name'],
      id: map['id'],
      items:
          List.from(List.from(map['items']).map((e) => PackingPlan.fromMap(e))),
      sports: List.from(map['sports']),
      equipmentId: map['equipmentId'],
      equipmentCount: (map['equipmentCount'] as num).toInt(),
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
    };
  }
}
