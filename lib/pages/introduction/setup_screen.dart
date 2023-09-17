import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/pages/setup/loading_page.dart';
import 'package:equipment_app/pages/setup/set_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../firebase/firebase_auth.dart';

enum EditValue {
  name,
  setUp,
}

class SetupScreen extends ConsumerWidget {
  SetupScreen({Key? key, required this.editValue}) : super(key: key);

  final newNameProvider = StateProvider<String>((ref) => '');
  final newImageProvider = StateProvider.autoDispose<Uint8List?>((ref) => null);
  final EditValue editValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController(initialPage: 0);

    void uploadToFirebase() async {
      /*if (editValue == EditValue.setUp) {
        Uint8List? image = ref.read(newImageProvider);
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
      }*/

      if (editValue == EditValue.setUp || editValue == EditValue.name) {
        String name = ref.read(newNameProvider);
        ref.invalidate(newNameProvider);
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(Auth().user?.uid);
        await docRef.set({
          "name": name,
          "isSetupCompleted": true,
        }, SetOptions(merge: true));
      }

      if (context.mounted) {
        editValue == EditValue.setUp ? context.go('/') : context.pop();
      }
    }

    void nextPage() {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }

    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            if (editValue == EditValue.setUp || editValue == EditValue.name)
              SetName(
                  buttonText: (editValue == EditValue.name)
                      ? ButtonText.doneText
                      : ButtonText.continueText,
                  onComplete: (newName) {
                    ref.read(newNameProvider.notifier).state = newName;
                    nextPage();
                  }),
            /*if (editValue == EditValue.setUp)
              SetImage(onComplete: (newImage) {
                ref.read(newImageProvider.notifier).state = newImage;
                nextPage();
              }),*/
            LoadingPage(
              onInit: () => uploadToFirebase(),
            ),
          ],
        ),
      ),
    );
  }
}
