import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_models/equipment.dart';
import '../data_models/packing_plan_item.dart';
import '../firebase/firebase_auth.dart';
import 'data.dart';

final authProvider = Provider<String>((ref) => ref.watch(authStateChangesProvider).value?.providerData.firstOrNull?.providerId ?? 'null');

final equipmentStreamProvider = StreamProvider<List<Equipment>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
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
  final user = ref.watch(authStateChangesProvider).value;

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('packing_plan')
      .orderBy("createdAt", descending: true)
      .withConverter(
        fromFirestore: PackingPlan.fromFirestore,
        toFirestore: (PackingPlan p, _) => p.toMap(),
      )
      .snapshots();
  return stream
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

final userDataStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;

  final firestoreStream = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .snapshots();

  return firestoreStream.map((event) => event.data() ?? {});
});

final packingPlanItemStreamProvider =
StreamProvider.autoDispose.family<List<PackingPlanItem>, String>((ref, packingPlanId) {
  final user = ref.watch(authStateChangesProvider).value;

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('packing_plan')
      .doc(packingPlanId)
      .collection('items')
      .withConverter(
    fromFirestore: PackingPlanItem.fromFirestore,
    toFirestore: (PackingPlanItem p, _) => p.toMap(),
  )
      .snapshots();

  return stream.map((snapshot) =>
      snapshot.docs.map((doc) => doc.data()).toList());
});

Widget getImagefromCategory ({required String category}) {
  String imageName = Data.getCategoryImageName(category);
  return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 1,
        minHeight: 1,
      ),
      child: Image.asset('assets/items/$imageName', errorBuilder: (context, object, stacktrace) => Image.asset('assets/items/0.0.4.4.png',)));
}