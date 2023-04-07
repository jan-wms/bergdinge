import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data_models/equipment.dart';
import '../firebase/firebase_auth.dart';

final equipmentStreamProvider = StreamProvider<List<Equipment>>((ref) {
  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .collection('equipment')
      .withConverter(
    fromFirestore: Equipment.fromFirestore,
    toFirestore: (Equipment e, _) => e.toMap(),
  )
      .snapshots();
  return stream
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

final packingPlanStreamProvider = StreamProvider<List<PackingPlan>>((ref) {
  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .collection('packing_plan')
      .withConverter(
    fromFirestore: PackingPlan.fromFirestore,
    toFirestore: (PackingPlan p, _) => p.toMap(),
  )
      .snapshots();
  return stream
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
