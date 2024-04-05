import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../custom_widgets/custom_close_button.dart';
import '../../../data/design.dart';
import '../../../firebase/firebase_auth.dart';

class ItemList extends ConsumerWidget {
  const ItemList(
      {super.key, required this.packingPlanId, required this.onEdit});

  final String packingPlanId;
  final void Function(String, int) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(packingPlanItemStreamProvider(packingPlanId)).when(
        error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
        data: (items) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: Container(),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                title: const Text('Checkliste'),
                actions: const [
                  CustomCloseButton(),
                ],
              ),
              SliverList.separated(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: Checkbox(
                        shape: const CircleBorder(),
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
                    title: Text(
                        '${item.equipmentId}x${item.location}@${item.equipmentCount}'),
                    trailing: IconButton(
                        onPressed: () =>
                            onEdit(item.equipmentId, item.location),
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.black54,
                        )),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Padding(
                    padding: Design.pagePadding,
                    child: Divider(
                      height: 0.0,
                    ),
                  );
                },
              )
            ],
          );
        });
  }
}
