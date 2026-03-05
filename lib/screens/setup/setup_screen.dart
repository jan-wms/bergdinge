import 'package:bergdinge/data/example_data.dart';
import 'package:bergdinge/models/equipment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bergdinge/screens/setup/loading_page.dart';
import 'package:bergdinge/screens/setup/set_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../data/design.dart';
import '../../firebase/firebase_auth.dart';
import '../../models/packing_plan_item.dart';
import '../../widgets/custom_sliver_app_bar.dart';

enum EditValue {
  name,
  setUp,
  none,
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.editValue});

  final EditValue editValue;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String name = '';

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);

    void uploadToFirebase() async {
      var timer = Future.delayed(
          Duration(seconds: widget.editValue == EditValue.setUp ? 4 : 2));

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(Auth().user?.uid);

      await userDocRef.set({
        "name": name,
        "isSetupCompleted": true,
      }, SetOptions(merge: true));

      // Load example data on first sign in.
      if (widget.editValue == EditValue.setUp) {
        for (final Equipment e in ExampleData.equipment) {
          DocumentReference ref = userDocRef.collection('equipment').doc(e.id);
          await ref.set(e.toMap());
        }

        DocumentReference packingPlanRef = userDocRef
            .collection('packing_plan')
            .doc(ExampleData.packingPlan.id);
        await packingPlanRef.set(ExampleData.packingPlan.toMap());

        for(PackingPlanItem i in ExampleData.packingPlanItems) {
          DocumentReference ref = packingPlanRef
              .collection('items')
              .doc(
              '${i.equipmentId}-${i.location.name}');

          await ref.set(i.toMap());
        }
      }

      timer.whenComplete(() {
        if (context.mounted) {
          widget.editValue == EditValue.setUp ? context.go('/') : context.pop();
        }
      });
    }

    return Material(
      color: (widget.editValue == EditValue.name &&
              (MediaQuery.of(context).size.width > Design.wideScreenBreakpoint))
          ? Colors.transparent
          : Colors.white,
      child: Container(
        constraints: (widget.editValue == EditValue.name &&
                (MediaQuery.of(context).size.width >
                    Design.wideScreenBreakpoint))
            ? const BoxConstraints(maxWidth: 600.0, maxHeight: 530.0)
            : null,
        child: SafeArea(
          top: false,
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              if (widget.editValue == EditValue.setUp || widget.editValue == EditValue.name)
                ClipRRect(
                  borderRadius: (widget.editValue == EditValue.name &&
                          (MediaQuery.of(context).size.width >
                              Design.wideScreenBreakpoint))
                      ? BorderRadius.circular(20.0)
                      : BorderRadius.zero,
                  child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: [
                      CustomSliverAppBar(
                          disableRoundedCorners: (widget.editValue == EditValue.setUp),
                          title: 'Bergdinge',
                          icon: Icons.terrain,
                          subtitle: 'Wie heißt du?'),
                      SliverFillRemaining(
                        child: SetName(
                            buttonText: (widget.editValue == EditValue.name)
                                ? ButtonText.doneText
                                : ButtonText.continueText,
                            onComplete: (newName) {
                              setState(() {
                                name = newName;
                              });
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
                  editValue: widget.editValue,
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
