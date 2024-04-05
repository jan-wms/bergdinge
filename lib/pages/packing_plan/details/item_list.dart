import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_checkbox.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../custom_widgets/custom_close_button.dart';
import '../../../data/design.dart';
import '../../../firebase/firebase_auth.dart';

class ItemList extends ConsumerWidget {
  final List<String> locations;
  const ItemList(
      {super.key, required this.packingPlanId, required this.onEdit, required this.locations});

  final String packingPlanId;
  final void Function(String, int) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.read(equipmentStreamProvider).when(
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const CircularProgressIndicator.adaptive(),
        data: (equipmentList) {
          return ref.watch(packingPlanItemStreamProvider(packingPlanId)).when(
              error: (error, stackTrace) => Center(
                    child: Text(error.toString()),
                  ),
              loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
              data: (items) {
                return Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      leading: Container(),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.0))),
                      title: const Text('Checkliste'),
                      actions: const [
                        CustomCloseButton(),
                      ],
                    ),
                    body: ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final PackingPlanItem item = items[index];
                        final Equipment equipment = equipmentList.singleWhere((element) => element.id == item.equipmentId);
                        return ListTile(
                          leading: CustomCheckBox(
                              value: item.isChecked,
                              onChanged: (value) {
                                DocumentReference docRef = FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(Auth().user?.uid)
                                    .collection('packing_plan')
                                    .doc(packingPlanId)
                                    .collection('items')
                                    .doc('${item.equipmentId}${item.location}');

                                docRef.update({'isChecked': value});
                              }),
                          title: Text(
                              '${equipment.brand} ${equipment.name} @${locations[item.location - 1]} ${item.equipmentCount}x'),
                          trailing: IconButton(
                            onPressed: () =>
                                onEdit(item.equipmentId, item.location),
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: Design.pagePadding
                              .add(const EdgeInsets.only(left: 45.0)),
                          child: const Divider(
                            height: 0.0,
                          ),
                        );
                      },
                    ));
              });
        });
  }
}
