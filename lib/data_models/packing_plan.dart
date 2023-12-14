import 'package:cloud_firestore/cloud_firestore.dart';

class PackingPlan {
  final String name;
  final List<String> sports;
  final List<String> locations;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  PackingPlan({
    required this.name,
    required this.sports,
    required this.id,
    required this.locations,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory PackingPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return PackingPlan(
      name: data?['name'],
      id: data?['id'],
      sports: List.from(data?['sports']),
      locations: List.from(data?['locations']),
      createdAt: DateTime.parse(data?['createdAt']),
      updatedAt: DateTime.parse(data?['updatedAt']),
      notes: data?['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "sports": sports,
      "locations": locations,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      if(notes != null) "notes": notes,
    };
  }
}
