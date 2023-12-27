import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data_models/packing_plan_item.dart';
import '../../../firebase/firebase_auth.dart';

class ItemList extends ConsumerWidget {
  const ItemList({super.key, required this.packingPlanId, required this.onEdit});
  final String packingPlanId;
  final void Function(String, int) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(packingPlanItemStreamProvider(packingPlanId)).when(
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => const CircularProgressIndicator.adaptive(),
      data: (items) {
        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () => context.pop(), icon: const Icon(Icons.close)),
            ),
            Expanded(
                child: ListView(children: [
                  for (PackingPlanItem item in items)
                    Row(
                      children: [
                        Text(
                            '${item.equipmentId}x${item.location}@${item.equipmentCount}'),
                        Checkbox(
                            value: item.isChecked,
                            onChanged: (value) {
                              DocumentReference docRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(Auth().user?.uid)
                                  .collection('packing_plan')
                                  .doc(packingPlanId)
                                  .collection('items')
                                  .doc('${item.equipmentId}${item.location}');

                              docRef.update({'isChecked': value});
                            }),
                        IconButton(
                            onPressed: () => onEdit(item.equipmentId, item.location),
                            icon: const Icon(Icons.more_vert_rounded)),
                      ],
                    )
                ]))
          ],
        );
      }
    );
  }
}
