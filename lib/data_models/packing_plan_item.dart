import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final List<PackingPlanItem>? items;
  final String equipmentId;
  final int equipmentCount;
  final bool isChecked;

  PackingPlanItem({
    this.items,
    required this.equipmentCount,
    required this.equipmentId,
    required this.isChecked,
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
      isChecked: data?['isChecked'],
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
      isChecked: data['isChecked'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (items != null) "items": items?.map((e) => e.toMap()),
      "equipmentId": equipmentId,
      "equipmentCount": equipmentCount,
      "isChecked": isChecked,
    };
  }
}
