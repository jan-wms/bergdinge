import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bergdinge/models/packing_plan.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/packing_plan_details_data.dart';
import 'firebase_auth.dart';
import '../models/equipment.dart';
import '../models/packing_plan_item.dart';

final userAuthProvider = Provider<String>((ref) =>
    ref
        .watch(authStateChangesProvider)
        .value
        ?.providerData
        .firstOrNull
        ?.providerId ??
    'null');

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
      .orderBy("name", descending: true)
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

  final firestoreStream =
      FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots();

  return firestoreStream.map((event) => event.data() ?? {});
});

final packingPlanItemStreamProvider = StreamProvider.autoDispose
    .family<List<PackingPlanItem>, String>((ref, packingPlanId) {
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

  return stream
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

final packingPlanDetailsProvider = Provider.autoDispose
    .family<AsyncValue<PackingPlanDetailsData>, String>((ref, packingPlanId) {
  final packingPlansAsync = ref.watch(packingPlanStreamProvider);
  final equipmentAsync = ref.watch(equipmentStreamProvider);
  final packingPlanItemsAsync =
      ref.watch(packingPlanItemStreamProvider(packingPlanId));

  if (packingPlanItemsAsync.isLoading ||
      packingPlansAsync.isLoading ||
      equipmentAsync.isLoading) {
    return AsyncValue.loading();
  }

  final error = packingPlansAsync.asError ??
      equipmentAsync.asError ??
      packingPlanItemsAsync.asError;

  if (error != null) {
    return AsyncValue.error(error.error, error.stackTrace);
  }

  final packingPlan =
      packingPlansAsync.value!.singleWhereOrNull((p) => p.id == packingPlanId);

  if(packingPlan == null) {
    return AsyncValue.loading();
  }

  final equipment = equipmentAsync.value!;
  final items = packingPlanItemsAsync.value!;

  return AsyncValue.data(PackingPlanDetailsData(
      packingPlan: packingPlan, equipment: equipment, items: items));
});