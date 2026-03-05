import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/sports.dart';

class PackingPlan {
  final String name;
  final List<String> sports;
  final String id;
  final String? notes;

  PackingPlan({
    required this.name,
    required this.sports,
    required this.id,
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
      notes: data?['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "sports": sports,
      if(notes != null) "notes": notes,
    };
  }

  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Erforderlich';
    }
    return null;
  }

  static String? validateNotes(dynamic value) {
    return null;
  }

  static String? validateSports(List<String>? value) {
    if (value == null || value.isEmpty) {
      return "Wähle mindestens eine Kategorie.";
    }
    for (var item in value) {
      if (!Sports.sports.contains(item)) {
        return "Fehler: Unbekannter Sport.";
      }
    }
    return null;
  }
}
