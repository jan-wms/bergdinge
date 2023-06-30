import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

final userDataStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final firestoreStream = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .snapshots();

  return firestoreStream.map((event) => event.data() ?? {});
});

final profilePictureStreamProvider = StreamProvider<ImageProvider<Object>>((ref) {
  final streamController = StreamController<ImageProvider<Object>>.broadcast();
  final firestoreStream = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .snapshots();

  firestoreStream.listen((event) async {
    String? imageValue = event.data()?['profilePicture'];
    ImageProvider<Object> newImage;
    if(imageValue == null) {
      newImage = Image.asset('assets/images/placeholder.jpg').image;
    }
    else {
      newImage = Image.memory((await FirebaseStorage.instance
          .ref()
          .child("users/${Auth().user!.uid}/profile.jpg").getData())!).image;
    }
    streamController.add(newImage);
  });

  return streamController.stream;
});