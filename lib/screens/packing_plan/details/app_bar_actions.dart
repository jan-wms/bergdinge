import 'package:bergdinge/models/packing_plan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/design.dart';
import '../../../firebase/firebase_auth.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/popupitem_extension.dart';
import '../packing_plan_edit.dart';

class AppBarActions extends StatelessWidget {
  final PackingPlan packingPlan;

  const AppBarActions({super.key, required this.packingPlan});

  Future<void> deletePackingPlan(BuildContext context) async {
    bool? confirmDelete = await CustomDialog.showCustomConfirmationDialog(
        type: ConfirmType.confirmDelete,
        context: context,
        description: 'Möchtest du diese Packliste wirklich löschen?');
    if (confirmDelete ?? false) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().user?.uid)
          .collection('packing_plan')
          .doc(packingPlan.id);

      final snapshot = await docRef.collection('items').get();
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }

      if (context.mounted) {
        context.pop();
      }
      await docRef.delete();
    }
  }

  Future<void> editPackingPlan(BuildContext context) async {
    CustomDialog.showCustomModal(
        context: context,
        child: PackingPlanEdit(
          packingPlan: packingPlan,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return TooltipVisibility(
      visible: false,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: PopupMenuButton(
          icon: const Icon(
            Icons.more_vert_rounded,
          ),
          iconColor: Colors.white,
          color: Colors.white,
          splashRadius: 100,
          offset: const Offset(-10, 0),
          surfaceTintColor: Colors.white,
          itemBuilder: (context) => [
            CustomPopupMenuItem(
                child: Padding(
              padding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Design.darkGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                onPressed: () {
                  context.pop();
                  editPackingPlan(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Bearbeiten'),
                    ),
                  ],
                ),
              ),
            )),
            CustomPopupMenuItem(
                child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                onPressed: () async {
                  context.pop();
                  deletePackingPlan(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_rounded),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Löschen'),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
