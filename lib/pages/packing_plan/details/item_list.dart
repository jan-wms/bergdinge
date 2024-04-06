import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_checkbox.dart';
import 'package:equipment_app/custom_widgets/popupitem_extension.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../custom_widgets/custom_close_button.dart';
import '../../../data/design.dart';
import '../../../firebase/firebase_auth.dart';

class ItemList extends ConsumerWidget {
  final List<String> locations;

  const ItemList(
      {super.key,
      required this.packingPlanId,
      required this.onEdit,
      required this.locations});

  final String packingPlanId;
  final void Function(String, int) onEdit;

  Future<void> toggle(
      {required String equipmentId,
      required int location,
      required bool newValue}) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .doc(packingPlanId)
        .collection('items')
        .doc('$equipmentId$location');

    docRef.update({'isChecked': newValue});
  }

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
                        final Equipment equipment = equipmentList.singleWhere(
                            (element) => element.id == item.equipmentId);

                        DocumentReference docRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(Auth().user?.uid)
                            .collection('packing_plan')
                            .doc(packingPlanId)
                            .collection('items')
                            .doc('${item.equipmentId}${item.location}');

                        return ListTile(
                          onTap: () => toggle(
                              equipmentId: item.equipmentId,
                              location: item.location,
                              newValue: !item.isChecked),
                          leading: CustomCheckBox(
                            value: item.isChecked,
                            onChanged: (value) => toggle(
                                equipmentId: item.equipmentId,
                                location: item.location,
                                newValue: value),
                          ),
                          title: Text(
                              '${equipment.brand} ${equipment.name} @${locations[item.location - 1]} ${item.equipmentCount}x'),
                          trailing: TooltipVisibility(
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
                                iconColor: Colors.black54,
                                color: Colors.white,
                                splashRadius: 100,
                                surfaceTintColor: Colors.white,
                                itemBuilder: (context) => [
                                  CustomPopupMenuItem(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                            onPressed: () {
                                              if (item.equipmentCount > 1) {
                                                docRef.update({
                                                  'equipmentCount':
                                                      (item.equipmentCount - 1)
                                                });
                                              }
                                            },
                                            child: const Icon(
                                                Icons.chevron_left_rounded)),
                                        Text(
                                          item.equipmentCount.toString(),
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        TextButton(
                                            style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                            onPressed: () => docRef.update({
                                                  'equipmentCount':
                                                      (item.equipmentCount + 1)
                                                }),
                                            child: const Icon(
                                                Icons.chevron_right_rounded)),
                                      ],
                                    ),
                                  ),
                                  CustomPopupMenuItem(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, top: 10.0),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                      onPressed: () => docRef
                                          .delete()
                                          .then((value) => context.pop()),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.delete_rounded),
                                          Text('Löschen'),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),

                          /*IconButton(
                            onPressed: () =>
                                onEdit(item.equipmentId, item.location),
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.black54,
                            ),
                          ),*/
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
