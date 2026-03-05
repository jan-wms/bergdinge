import 'dart:math';

import 'package:bergdinge/firebase/firebase_data_providers.dart';
import 'package:bergdinge/models/packing_plan_details_data.dart';
import 'package:bergdinge/screens/packing_plan/details/analysis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/category_data.dart';
import '../../../data/design.dart';
import '../../../firebase/firebase_auth.dart';
import '../../../models/packing_plan_item.dart';
import '../../../models/packing_plan_location.dart';
import '../../../models/statistic.dart';
import '../../../widgets/custom_checkbox.dart';
import '../../../widgets/popupitem_extension.dart';

class ListSection extends ConsumerWidget {
  final PackingPlanDetailsData data;
  final PackingPlanLocation? locationSource;

  const ListSection({super.key, this.locationSource, required this.data});

  Future<void> toggleIsChecked(
      {required BuildContext context,
      required bool value,
      required PackingPlanItem item}) async {
    if (locationSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: min(MediaQuery.of(context).size.width * 0.9, 500),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Text(
              "Wähle zum Bearbeiten oben ${PackingPlanLocation.values.map((l) => l.label).join(' oder ')} aus."),
        ),
      );
    } else {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().user?.uid)
          .collection('packing_plan')
          .doc(data.packingPlan.id)
          .collection('items')
          .doc('${item.equipmentId}-${locationSource!.name}');

      docRef.update({'isChecked': value});
    }
  }

  void showEquipmentDetails(BuildContext context, String equipmentId) {
    context.pushNamed('equipmentDetails',
        pathParameters: {'equipmentId': equipmentId},
        extra: {'transitionDelay': 0});
  }

  Future<void> deleteItem(BuildContext context, String equipmentId) async {
    if (context.mounted) {
      context.pop();
    }
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .doc(data.packingPlan.id)
        .collection('items')
        .doc('$equipmentId-${locationSource!.name}');
    await docRef.delete();
  }

  Future<void> setItemCount(String equipmentId, int count) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('packing_plan')
        .doc(data.packingPlan.id)
        .collection('items')
        .doc('$equipmentId-${locationSource!.name}');

    await docRef.update({'equipmentCount': (count)});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistic = ref.watch(statisticProvider).lastOrNull;
    if (statistic == null) return Container();
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 600.0,
      ),
      padding: Design.pagePadding,
      child: Column(
        children: [
          for (MapEntry<String, List<PackingPlanItem>> entry
              in statistic.categoryItemsMap.entries)
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          CategoryData.flatMapCategories(entry.key).last.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          statistic.absoluteRelativeFromGroup(
                              entry.key, data.equipment),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (PackingPlanItem item in locationSource == null ? Statistic.sumUpAllLocations(entry.value) : entry.value) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () =>
                          showEquipmentDetails(context, item.equipmentId),
                      leading: CustomCheckBox(
                        disabledColor: locationSource == null,
                        isChecked: locationSource == null
                            ? false
                            : (data.items
                                    .singleWhereOrNull((element) =>
                                        element.equipmentId ==
                                            item.equipmentId &&
                                        element.location == locationSource)
                                    ?.isChecked) ??
                                false,
                        onChanged: (value) => toggleIsChecked(
                            context: context, value: value, item: item),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                                '${data.equipment.singleWhereOrNull((element) => element.id == item.equipmentId)?.brand} ${data.equipment.singleWhereOrNull((element) => element.id == item.equipmentId)?.name}'),
                          ),
                          if (item.equipmentCount > 1)
                            Container(
                              margin: const EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                color: (data.equipment
                                            .singleWhereOrNull((element) =>
                                                element.id == item.equipmentId)
                                            ?.category ==
                                        '3.0')
                                    ? Colors.blue
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5.0),
                              child: Text(
                                '${item.equipmentCount}${(data.equipment.singleWhereOrNull((element) => element.id == item.equipmentId)?.category == '3.0') ? ' ml' : 'x'}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                      trailing: locationSource == null
                          ? null
                          : TooltipVisibility(
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
                                  offset: const Offset(-10, 0),
                                  surfaceTintColor: Colors.white,
                                  itemBuilder: (context) {
                                    final isDrink = (data.equipment
                                            .singleWhereOrNull((element) =>
                                                element.id == item.equipmentId)
                                            ?.category ==
                                        '3.0');

                                    return [
                                      CustomPopupMenuItem(
                                        child: Consumer(
                                            builder: (context, ref, _) {
                                          final i = ref
                                              .watch(
                                                  packingPlanItemStreamProvider(
                                                      data.packingPlan.id))
                                              .value
                                              ?.singleWhereOrNull((element) =>
                                                  element.equipmentId ==
                                                      item.equipmentId &&
                                                  element.location ==
                                                      locationSource);

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                  style: TextButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                  onPressed: () {
                                                    if (i != null &&
                                                        ((isDrink &&
                                                                i.equipmentCount >
                                                                    50) ||
                                                            (!isDrink &&
                                                                i.equipmentCount >
                                                                    1))) {
                                                      setItemCount(
                                                          item.equipmentId,
                                                          isDrink
                                                              ? i.equipmentCount -
                                                                  50
                                                              : i.equipmentCount -
                                                                  1);
                                                    }
                                                  },
                                                  child: const Icon(Icons
                                                      .chevron_left_rounded)),
                                              Text(
                                                '${i?.equipmentCount.toString() ?? ''}${isDrink ? ' ml' : ''}',
                                                style: const TextStyle(
                                                    fontSize: 17),
                                              ),
                                              TextButton(
                                                  style: TextButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                  onPressed: () {
                                                    if (i != null) {
                                                      setItemCount(
                                                          item.equipmentId,
                                                          isDrink
                                                              ? i.equipmentCount +
                                                                  50
                                                              : i.equipmentCount +
                                                                  1);
                                                    }
                                                  },
                                                  child: const Icon(Icons
                                                      .chevron_right_rounded)),
                                            ],
                                          );
                                        }),
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
                                                        BorderRadius.circular(
                                                            10.0))),
                                            onPressed: () => deleteItem(
                                                context, item.equipmentId),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.delete_rounded),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Text('Löschen'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ),
                    ),
                    if (entry.value.last != item)
                      const Padding(
                        padding: EdgeInsets.only(left: 80.0, right: 30.0),
                        child: Divider(
                          height: 5.0,
                        ),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
