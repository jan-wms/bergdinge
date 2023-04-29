import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanDetails extends StatelessWidget {
  final PackingPlan packingPlan;
  const PackingPlanDetails({Key? key, required this.packingPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackButton(
          onPressed: () {
            if(context.canPop()) {
              context.pop();
            }
          },
        ),
        Text(packingPlan.name),
        for (var sport in packingPlan.sports) Text(sport),
        for (var item in packingPlan.items) Text(item.equipmentId),
        ElevatedButton(
            onPressed: () async {

              bool? confirmDelete = await CustomDialog.showCustomConfirmationDialog(
                  context: context, description: "Wirklich löschen?");
              if(confirmDelete ?? false) {
                await FirebaseFirestore.instance
                  .collection('users')
                  .doc(Auth().user?.uid)
                  .collection('packing_plan')
                  .doc(packingPlan.id).delete().then((value) => context.pop());
              }
            },
            child: const Text('delete')),
        ElevatedButton(
            onPressed: () {
              context.push('/packing_plan/edit', extra: packingPlan);
            },
            child: const Text('edit')),
      ],
    );
  }
}
