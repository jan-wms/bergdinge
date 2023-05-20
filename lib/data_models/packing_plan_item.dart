import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final String equipmentId;
  final int equipmentCount;

  PackingPlanItem(
      {required this.equipmentId, required this.equipmentCount});


  factory PackingPlanItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlanItem(
      equipmentId: data?['equipmentId'],
      equipmentCount: (data?['equipmentCount'] as num).toInt(),
    );
  }

  factory PackingPlanItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return PackingPlanItem(
      equipmentId: map['equipmentId'],
      equipmentCount: (map['equipmentCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "equipmentId": equipmentId,
      "equipmentCount": equipmentCount,
    };
  }
}
