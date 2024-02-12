import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_appbar.dart';
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
  final EditValue editValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController(initialPage: 0);

    void uploadToFirebase() async {
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
        top: false,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            if (editValue == EditValue.setUp || editValue == EditValue.name)
              CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  const CustomAppBar(
                      title: 'Bergdinge',
                      icon: Icons.terrain,
                      subtitle: 'Wie heißt du?'),
                  SliverFillRemaining(
                    child: SetName(
                        buttonText: (editValue == EditValue.name)
                            ? ButtonText.doneText
                            : ButtonText.continueText,
                        onComplete: (newName) {
                          ref.read(newNameProvider.notifier).state = newName;
                          nextPage();
                        }),
                  ),
                ],
              ),
            LoadingPage(
              onInit: () => uploadToFirebase(),
            )
          ],
        ),
      ),
    );
  }
}
