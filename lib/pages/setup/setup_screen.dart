import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bergdinge/custom_widgets/custom_appbar.dart';
import 'package:bergdinge/pages/setup/loading_page.dart';
import 'package:bergdinge/pages/setup/set_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/design.dart';
import '../../firebase/firebase_auth.dart';

enum EditValue {
  name,
  setUp,
}

class SetupScreen extends ConsumerWidget {
  SetupScreen({super.key, required this.editValue});

  final newNameProvider = StateProvider<String>((ref) => '');
  final EditValue editValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController(initialPage: 0);

    void uploadToFirebase() async {
      var timer = Future.delayed(const Duration(seconds: 2));

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

      timer.whenComplete(() {
        if (context.mounted) {
          editValue == EditValue.setUp ? context.go('/') : context.pop();
        }
      });
    }

    return Material(
      color: (editValue == EditValue.name && (MediaQuery.of(context).size.width > Design.breakpoint1)) ? Colors.transparent : Colors.white,
      child: Container(
        constraints: (editValue == EditValue.name && (MediaQuery.of(context).size.width > Design.breakpoint1)) ? const BoxConstraints(
          maxWidth:  600.0,
          maxHeight: 530.0
        ) : null,
        child: SafeArea(
        top: false,
        child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              if (editValue == EditValue.setUp || editValue == EditValue.name)
                ClipRRect(
                  borderRadius: (editValue == EditValue.name && (MediaQuery.of(context).size.width > Design.breakpoint1)) ? BorderRadius.circular(20.0) : BorderRadius.zero,
                  child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: [
                      CustomAppBar(
                          disableRoundedCorners: (editValue == EditValue.setUp),
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
                                    pageController.jumpToPage(1);
                                  }),
                          ),
                    ],
                  ),
                ),
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.black, // Android
                    statusBarBrightness: Brightness.light // iOS
                    ),
                child: LoadingPage(
                  editValue: editValue,
                  onInit: () => uploadToFirebase(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
