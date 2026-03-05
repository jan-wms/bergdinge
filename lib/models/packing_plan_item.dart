import 'package:bergdinge/models/packing_plan_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlanItem {
  final String equipmentId;
  int equipmentCount;
  bool isChecked;
  final PackingPlanLocation location;

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
      location: PackingPlanLocation.values.firstWhere((e) => e.name == data?['location']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "equipmentId": equipmentId,
      "equipmentCount": equipmentCount,
      "isChecked": isChecked,
      "location": location.name
    };
  }
}
