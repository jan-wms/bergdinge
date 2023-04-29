import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final String equipmentId;
  final int count;

  PackingPlanItem(
      {required this.equipmentId, required this.count});


  factory PackingPlanItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlanItem(
      equipmentId: data?['equipmentId'],
      count: (data?['count'] as num).toInt(),
    );
  }

  factory PackingPlanItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return PackingPlanItem(
      equipmentId: map['equipmentId'],
      count: (map['count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "equipmentId": equipmentId,
      "count": count,
    };
  }
}
