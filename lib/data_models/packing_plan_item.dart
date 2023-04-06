import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final String equipmentId;
  final int count;
  final String place;

  PackingPlanItem(
      {required this.equipmentId, required this.place, required this.count});


  factory PackingPlanItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlanItem(
      equipmentId: data?['equipmentId'],
      place: data?['place'],
      count: (data?['count'] as num).toInt(),
    );
  }

  factory PackingPlanItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return PackingPlanItem(
      equipmentId: map['equipmentId'],
      place: map['place']!,
      count: (map['count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "equipmentId": equipmentId,
      "count": count,
      "place": place,
    };
  }
}
