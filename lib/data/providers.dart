import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_models/equipment.dart';
import '../firebase/firebase_auth.dart';

final equipmentStreamProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .collection('equipment')
      .withConverter(
    fromFirestore: Equipment.fromFirestore,
    toFirestore: (Equipment e, _) => e.toMap(),
  )
      .snapshots();
});