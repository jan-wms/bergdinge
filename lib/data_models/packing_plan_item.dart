import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final List<PackingPlanItem>? items;
  final String equipmentId;
  final int equipmentCount;

  PackingPlanItem({
    this.items,
    required this.equipmentCount,
    required this.equipmentId,
  });

  factory PackingPlanItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PackingPlanItem(
      items: data?['items'] != null
          ? List<PackingPlanItem>.from(
              List.from(data?['items']).map((e) => PackingPlanItem.fromMap(e)))
          : null,
      equipmentId: data?['equipmentId'],
      equipmentCount: (data?['equipmentCount'] as num).toInt(),
    );
  }

  factory PackingPlanItem.fromMap(Map<String, dynamic> data) {
    return PackingPlanItem(
      items: data['items'] != null
          ? List.from(
              List.from(data['items']).map((e) => PackingPlanItem.fromMap(e)))
          : null,
      equipmentId: data['equipmentId'],
      equipmentCount: (data['equipmentCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (items != null) "items": items?.map((e) => e.toMap()),
      "equipmentId": equipmentId,
      "equipmentCount": equipmentCount,
    };
  }
}
