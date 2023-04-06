import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';

class PackingPlanItem {
  final Equipment equipment;
  final int count;
  final String place;

  PackingPlanItem(
      {required this.equipment, required this.place, required this.count});


  factory PackingPlanItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return PackingPlanItem(
      equipment: Equipment.fromMap(data?['equipment']),
      place: data?['place'],
      count: (data?['count'] as num).toInt(),
    );
  }

  factory PackingPlanItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return PackingPlanItem(
      equipment: Equipment.fromMap(map['equipment'] as Map<String, dynamic>),
      place: map['place']!,
      count: (map['count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "equipment": equipment.toMap(),
      "count": count,
      "place": place,
    };
  }
}
