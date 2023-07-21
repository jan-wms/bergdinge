import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/pages/setup/set_image.dart';
import 'package:equipment_app/pages/setup/set_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../firebase/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


class SetupScreen extends ConsumerWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController(initialPage: 0);

    Future<void> uploadToFirebase() async {
      String name = ref.read(newNameProvider);
      Uint8List? image = ref.read(newImageProvider);

      ref.invalidate(newNameProvider);
      ref.invalidate(newImageProvider);

      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef =
        storageRef.child("users/${Auth().user!.uid}/profile.jpg");
        await imageRef
            .putData(
            image,
            SettableMetadata(
              contentType: "image/jpg",
            ))
            .then((p0) => FirebaseFirestore.instance
            .collection("users")
            .doc(Auth().user?.uid)
            .set({
          "profilePicture": DateTime.now().toIso8601String(),
        }));
      }

      DocumentReference docRef =
      FirebaseFirestore.instance.collection('users').doc(Auth().user?.uid);
      await docRef.set({
        "name": name,
        "isSetupCompleted": true,
      }, SetOptions(merge: true)).then((value) => context.go('/'));
    }

    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
              SetName(buttonText: ButtonText.continueText, onComplete: () {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }),
              SetImage(onComplete: () {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 300), curve: Curves.easeInOut).then((value) => uploadToFirebase());
              }),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator.adaptive(),
                  Text('App wird eingerichtet...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
