import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final String equipmentId;
  final int equipmentCount;
  final bool isChecked;
  final String location;

  PackingPlanItem({
    required this.equipmentCount,
    required this.equipmentId,
    required this.isChecked,
    required this.location,
  });

  factory PackingPlanItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PackingPlanItem(
      equipmentId: data?['equipmentId'],
      equipmentCount: (data?['equipmentCount'] as num).toInt(),
      isChecked: data?['isChecked'],
      location: data?['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "equipmentId": equipmentId,
      "equipmentCount": equipmentCount,
      "isChecked": isChecked,
      "location": location
    };
  }
}
