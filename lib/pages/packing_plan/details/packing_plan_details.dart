import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:equipment_app/custom_widgets/custom_small_appbar.dart';
import 'package:equipment_app/custom_widgets/custom_close_button.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data/design.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:equipment_app/pages/equipment/equipment_list.dart';
import 'package:equipment_app/pages/packing_plan/details/edit_item.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_edit.dart';
import 'package:equipment_app/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../custom_widgets/custom_checkbox.dart';
import '../../../custom_widgets/custom_dialog.dart';
import '../../../custom_widgets/popupitem_extension.dart';
import '../../../data_models/tip.dart';
import '../../../firebase/firebase_auth.dart';
import '../../../validators/packing_plan_validator.dart';
import 'custom_pie_chart.dart';

class PackingPlanDetails extends ConsumerStatefulWidget {
  final String packingPlanID;

  const PackingPlanDetails({super.key, required this.packingPlanID});

  @override
  ConsumerState<PackingPlanDetails> createState() => _PackingPlanDetailsState();
}

class _PackingPlanDetailsState extends ConsumerState<PackingPlanDetails> {
  final dropdownIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
  final _formKey = GlobalKey<FormState>();
  final pageController = PageController(initialPage: 0);
  final pageIndexProvider = StateProvider<List<int>>((ref) => [0, -1]);

  final Widget _loading = const CustomScrollView(
    slivers: [
      CustomSmallAppBar(title: ''),
      SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    //TODO
    //bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ref.watch(equipmentStreamProvider).when(
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: () => _loading,
          data: (equipmentList) {
            return ref.watch(packingPlanStreamProvider).when(
                  error: (error, stackTrace) =>
                      Center(child: Text(error.toString())),
                  loading: () => _loading,
                  data: (packingPlanList) {
                    final PackingPlan packingPlan =
                        packingPlanList.singleWhereOrNull((element) =>
                                element.id == widget.packingPlanID) ??
                            PackingPlan(
                                name: '',
                                sports: [],
                                id: '',
                                locations: [],
                                createdAt: DateTime(0),
                                updatedAt: DateTime(0));
                    return ref
                        .watch(packingPlanItemStreamProvider(packingPlan.id))
                        .when(
                          error: (error, stackTrace) =>
                              Center(child: Text(error.toString())),
                          loading: () => _loading,
                          data: (items) {
                            final TextEditingController controllerNotes =
                                TextEditingController(
                                    text: packingPlan.notes ?? '');

                            Statistic statisticFromItems(
                                MapEntry<String, List<PackingPlanItem>?>
                                    entry) {
                              Map<String, List<PackingPlanItem>>
                                  categoryPackingPlanItemsMap = {};
                              for (PackingPlanItem i in entry.value ?? []) {
                                Equipment e = equipmentList.singleWhere(
                                    (element) => element.id == i.equipmentId);
                                String topCategory =
                                    e.category.substring(entry.key.length);
                                topCategory = entry.key +
                                    ((topCategory.contains('.', 1))
                                        ? topCategory.substring(
                                            0, topCategory.indexOf('.', 1))
                                        : topCategory);

                                categoryPackingPlanItemsMap
                                        .containsKey(topCategory)
                                    ? categoryPackingPlanItemsMap[topCategory]!
                                        .add(i)
                                    : categoryPackingPlanItemsMap[topCategory] =
                                        [i];
                              }

                              if (categoryPackingPlanItemsMap.length == 1 &&
                                  !categoryPackingPlanItemsMap.keys.single
                                      .startsWith('2') &&
                                  !categoryPackingPlanItemsMap.keys.single
                                      .startsWith('3') &&
                                  categoryPackingPlanItemsMap.keys.single
                                          .split('.')
                                          .length <
                                      3) {
                                Statistic s = statisticFromItems(
                                    categoryPackingPlanItemsMap.entries.first);
                                categoryPackingPlanItemsMap =
                                    s.categoryPackingPlanItemsMap;
                              }

                              return Statistic(
                                  topCategory: entry.key,
                                  categoryPackingPlanItemsMap:
                                      categoryPackingPlanItemsMap,
                                  ref: ref);
                            }

                            List<Statistic> statistics = [
                              statisticFromItems(MapEntry(
                                  '',
                                  items
                                      .where((element) =>
                                          ref.watch(dropdownIndexProvider) == 0
                                              ? true
                                              : element.location ==
                                                  ref.read(
                                                      dropdownIndexProvider))
                                      .toList())),
                            ];

                            for (MapEntry<String, List<PackingPlanItem>> entry
                                in statistics.first.categoryPackingPlanItemsMap
                                    .entries) {
                              //TODO
                              try {
                                statistics.add(statisticFromItems(entry));
                              } catch (e) {}
                            }

                            List<Widget> getRightSection(Statistic statistic) {
                              var result = <Widget>[];

                              Map<String, List<PackingPlanItem>>
                                  summarizedItems = {};
                              for (MapEntry<String, List<PackingPlanItem>> entry
                                  in statistic
                                      .categoryPackingPlanItemsMap.entries) {
                                Map<String, int> sumMap = {};
                                for (PackingPlanItem p in entry.value) {
                                  sumMap[p.equipmentId] =
                                      (sumMap[p.equipmentId] ?? 0) +
                                          p.equipmentCount;
                                }
                                summarizedItems[entry.key] = sumMap.keys
                                    .map((e) => PackingPlanItem(
                                        location: 0,
                                        equipmentCount: sumMap[e] ?? 0,
                                        equipmentId: e,
                                        isChecked: false))
                                    .toList();
                              }

                              for (MapEntry<String, List<PackingPlanItem>> entry
                                  in summarizedItems.entries) {
                                result.add(Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: Design.pagePadding,
                                        child: Text(
                                          Data.getCategoryNames(entry.key).last,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                      for (PackingPlanItem item
                                          in entry.value) ...[
                                        ListTile(
                                          onTap: () => context.push(
                                              '/equipment/details',
                                              extra: item.equipmentId),
                                          leading: CustomCheckBox(
                                            disabled: (ref.read(
                                                        dropdownIndexProvider) ==
                                                    0)
                                                ? true
                                                : false,
                                            value: (ref.read(
                                                        dropdownIndexProvider) ==
                                                    0)
                                                ? false
                                                : items
                                                    .singleWhere((element) =>
                                                        element.equipmentId ==
                                                            item.equipmentId &&
                                                        element.location ==
                                                            ref.read(
                                                                dropdownIndexProvider))
                                                    .isChecked,
                                            onChanged: (value) async {
                                              if (ref.read(
                                                      dropdownIndexProvider) ==
                                                  0) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    width: min(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                        500),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    showCloseIcon: true,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    content: const Text(
                                                        "Wähle zum Bearbeiten oben den Ort aus, zum Beispiel Rucksack oder Anzug."),
                                                  ),
                                                );
                                              } else {
                                                DocumentReference docRef =
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(Auth().user?.uid)
                                                        .collection(
                                                            'packing_plan')
                                                        .doc(packingPlan.id)
                                                        .collection('items')
                                                        .doc(
                                                            '${item.equipmentId}${ref.read(dropdownIndexProvider)}');

                                                docRef.update(
                                                    {'isChecked': value});
                                              }
                                            },
                                          ),
                                          title: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                    '${equipmentList.singleWhere((element) => element.id == item.equipmentId).brand} ${equipmentList.singleWhere((element) => element.id == item.equipmentId).name}'),
                                              ),
                                              if (item.equipmentCount > 1)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10.0),
                                                  decoration: BoxDecoration(
                                                    color: (equipmentList
                                                                .singleWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        item.equipmentId)
                                                                .category ==
                                                            '3.0')
                                                        ? Colors.blue
                                                        : Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 5.0),
                                                  child: Text(
                                                    '${item.equipmentCount}${(equipmentList.singleWhere((element) => element.id == item.equipmentId).category == '3.0') ? ' ml' : 'x'}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          trailing: (ref.read(
                                                      dropdownIndexProvider) !=
                                                  0)
                                              ? TooltipVisibility(
                                                  visible: false,
                                                  child: Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      splashFactory: NoSplash
                                                          .splashFactory,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      splashColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: PopupMenuButton(
                                                      icon: const Icon(
                                                        Icons.more_vert_rounded,
                                                      ),
                                                      iconColor: Colors.black54,
                                                      color: Colors.white,
                                                      splashRadius: 100,
                                                      offset:
                                                          const Offset(-10, 0),
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      itemBuilder: (context) {
                                                        bool isLiquid = (equipmentList
                                                                .singleWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        item.equipmentId)
                                                                .category ==
                                                            '3.0');

                                                        return [
                                                          CustomPopupMenuItem(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                TextButton(
                                                                    style: TextButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10.0))),
                                                                    onPressed:
                                                                        () {
                                                                      if ((ref.watch(packingPlanItemStreamProvider(packingPlan.id)).value?.singleWhere((element) => element.equipmentId == item.equipmentId && element.location == ref.read(dropdownIndexProvider)).equipmentCount ??
                                                                              0) >
                                                                          (isLiquid
                                                                              ? 50
                                                                              : 1)) {
                                                                        DocumentReference docRef = FirebaseFirestore
                                                                            .instance
                                                                            .collection('users')
                                                                            .doc(Auth().user?.uid)
                                                                            .collection('packing_plan')
                                                                            .doc(packingPlan.id)
                                                                            .collection('items')
                                                                            .doc('${item.equipmentId}${ref.read(dropdownIndexProvider)}');

                                                                        int newValue = (ref.watch(packingPlanItemStreamProvider(packingPlan.id)).value?.singleWhere((element) => element.equipmentId == item.equipmentId && element.location == ref.read(dropdownIndexProvider)).equipmentCount ??
                                                                                0) -
                                                                            (isLiquid
                                                                                ? 50
                                                                                : 1);

                                                                        docRef
                                                                            .update({
                                                                          'equipmentCount':
                                                                              (newValue)
                                                                        });
                                                                      }
                                                                    },
                                                                    child: const Icon(
                                                                        Icons
                                                                            .chevron_left_rounded)),
                                                                Consumer(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      WidgetRef
                                                                          ref,
                                                                      child) {
                                                                    return Text(
                                                                      '${ref.watch(packingPlanItemStreamProvider(packingPlan.id)).value?.singleWhereOrNull((element) => element.equipmentId == item.equipmentId && element.location == ref.read(dropdownIndexProvider))?.equipmentCount.toString() ?? ''}${isLiquid ? ' ml' : ''}',
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              17),
                                                                    );
                                                                  },
                                                                ),
                                                                TextButton(
                                                                    style: TextButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                10.0))),
                                                                    onPressed:
                                                                        () {
                                                                      DocumentReference docRef = FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .doc(Auth()
                                                                              .user
                                                                              ?.uid)
                                                                          .collection(
                                                                              'packing_plan')
                                                                          .doc(packingPlan
                                                                              .id)
                                                                          .collection(
                                                                              'items')
                                                                          .doc(
                                                                              '${item.equipmentId}${ref.read(dropdownIndexProvider)}');

                                                                      int newValue = (ref.watch(packingPlanItemStreamProvider(packingPlan.id)).value?.singleWhere((element) => element.equipmentId == item.equipmentId && element.location == ref.read(dropdownIndexProvider)).equipmentCount ??
                                                                              0) +
                                                                          (isLiquid
                                                                              ? 50
                                                                              : 1);

                                                                      docRef
                                                                          .update({
                                                                        'equipmentCount':
                                                                            (newValue)
                                                                      });
                                                                    },
                                                                    child: const Icon(
                                                                        Icons
                                                                            .chevron_right_rounded)),
                                                              ],
                                                            ),
                                                          ),
                                                          CustomPopupMenuItem(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5.0,
                                                                      right:
                                                                          5.0,
                                                                      top:
                                                                          10.0),
                                                              child: TextButton(
                                                                style: TextButton.styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .red,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0))),
                                                                onPressed:
                                                                    () async {
                                                                  DocumentReference docRef = FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'users')
                                                                      .doc(Auth()
                                                                          .user
                                                                          ?.uid)
                                                                      .collection(
                                                                          'packing_plan')
                                                                      .doc(packingPlan
                                                                          .id)
                                                                      .collection(
                                                                          'items')
                                                                      .doc(
                                                                          '${item.equipmentId}${ref.read(dropdownIndexProvider)}');
                                                                  docRef
                                                                      .delete()
                                                                      .then((value) =>
                                                                          context
                                                                              .pop());
                                                                },
                                                                child:
                                                                    const Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(Icons
                                                                        .delete_rounded),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              8.0),
                                                                      child: Text(
                                                                          'Löschen'),
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
                                                )
                                              : null,
                                        ),
                                        if (entry.value.last != item)
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                left: 80.0, right: 30.0),
                                            child: Divider(
                                              height: 5.0,
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ));
                              }
                              return result;
                            }

                            Statistic getCurrentStatistic() {
                              return (ref.watch(pageIndexProvider).last != -1 &&
                                      statistics[ref.watch(pageIndexProvider).first]
                                              .categoryPackingPlanItemsMap
                                              .entries
                                              .length >
                                          1 &&
                                      statistics[ref
                                                  .watch(pageIndexProvider)
                                                  .first]
                                              .topCategory !=
                                          '3' &&
                                      statistics[ref
                                                  .watch(pageIndexProvider)
                                                  .first]
                                              .topCategory !=
                                          '2')
                                  ? statisticFromItems(MapEntry(
                                      statistics[
                                              ref.read(pageIndexProvider).first]
                                          .categoryPackingPlanItemsMap
                                          .entries
                                          .elementAt(
                                              ref.watch(pageIndexProvider).last)
                                          .key,
                                      statistics[
                                              ref.read(pageIndexProvider).first]
                                          .categoryPackingPlanItemsMap
                                          .entries
                                          .elementAt(
                                              ref.watch(pageIndexProvider).last)
                                          .value))
                                  : statistics[ref.read(pageIndexProvider).first];
                            }

                            return CustomScrollView(
                              slivers: [
                                CustomSmallAppBar(
                                  title: packingPlan.name,
                                  actions: [
                                    TooltipVisibility(
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
                                                    foregroundColor:
                                                        Design.colors[0],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0))),
                                                onPressed: () {
                                                  context.pop();
                                                  CustomDialog.showCustomModal(
                                                      context: context,
                                                      child: PackingPlanEdit(
                                                        packingPlan:
                                                            packingPlan,
                                                      ));
                                                },
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.edit_rounded),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8.0),
                                                      child: Text('Bearbeiten'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                            CustomPopupMenuItem(
                                                child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0,
                                                  right: 5.0,
                                                  top: 10.0),
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0))),
                                                onPressed: () async {
                                                  context.pop();
                                                  bool? confirmDelete =
                                                      await CustomDialog
                                                          .showCustomConfirmationDialog(
                                                              type: ConfirmType
                                                                  .confirmDelete,
                                                              context: context,
                                                              description:
                                                                  'Möchtest du diese Packliste wirklich löschen?');
                                                  if (confirmDelete ?? false) {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(Auth().user?.uid)
                                                        .collection(
                                                            'packing_plan')
                                                        .doc(packingPlan.id)
                                                        .delete()
                                                        .then((value) =>
                                                            context.pop());
                                                  }
                                                },
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
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.only(
                                    top: 20.0,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate(
                                      [
                                        Container(
                                          margin: Design.pagePadding,
                                          padding: const EdgeInsets.all(15.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                spreadRadius: 4,
                                                blurRadius: 10,
                                                offset: const Offset(2, 3),
                                              ),
                                            ],
                                          ),
                                          child: Flex(
                                            direction: Axis.vertical,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 0.0,
                                                  bottom: 15.0,
                                                ),
                                                child: Wrap(
                                                  runSpacing: 13.0,
                                                  spacing: 13.0,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  children: [
                                                    for (var sport
                                                        in packingPlan.sports)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    13.0,
                                                                vertical: 9.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromRGBO(
                                                              218, 231, 208, 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Text(
                                                          sport,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            color: Design
                                                                .colors[0],
                                                          ),
                                                        ),
                                                      ),
                                                    GestureDetector(
                                                      onTap: () => CustomDialog
                                                          .showCustomModal(
                                                              context: context,
                                                              child:
                                                                  PackingPlanEdit(
                                                                packingPlan:
                                                                    packingPlan,
                                                              )),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    15.0,
                                                                vertical: 8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromRGBO(240,
                                                              240, 240, 1.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Icon(
                                                          Icons.add_rounded,
                                                          size: 22,
                                                          color:
                                                              Design.colors[0],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Form(
                                                key: _formKey,
                                                child: TextFormField(
                                                  autofocus: false,
                                                  validator: (value) =>
                                                      PackingPlanValidator
                                                          .notes(value),
                                                  controller: controllerNotes,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Notizen',
                                                    alignLabelWithHint: true,
                                                  ),
                                                  minLines: 2,
                                                  maxLines: 6,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  onTapOutside: (value) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      DocumentReference ref =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(Auth()
                                                                  .user
                                                                  ?.uid)
                                                              .collection(
                                                                  'packing_plan')
                                                              .doc(packingPlan
                                                                  .id);

                                                      ref.update({
                                                        "notes":
                                                            controllerNotes.text
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: Design.pagePadding.copyWith(
                                              top: 40.0, bottom: 40.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor:
                                                      Design.colors[0],
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons
                                                        .lightbulb_rounded),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                        'Tipps',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  CustomDialog.showCustomModal(
                                                      context: context,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 20.0,
                                                                    bottom:
                                                                        10.0),
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Tipps',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          21,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child:
                                                                      CustomCloseButton(),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Divider(
                                                            indent: 15,
                                                            endIndent: 15,
                                                            height: 1,
                                                            color: Colors.grey,
                                                          ),
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount: Data
                                                                  .tips
                                                                  .where((element) =>
                                                                      element.isRelevant(
                                                                          packingPlan))
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                Tip tip = Data
                                                                    .tips
                                                                    .where((element) =>
                                                                        element.isRelevant(
                                                                            packingPlan))
                                                                    .toList()[index];
                                                                return _TipCard(
                                                                  tip: tip,
                                                                  isConditionMet:
                                                                      tip.isConditionMet(
                                                                          items,
                                                                          equipmentList),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ));
                                                },
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor:
                                                      Design.colors[0],
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.add),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                        'Ausrüstung',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () =>
                                                    CustomDialog
                                                        .showCustomModal(
                                                            context: context,
                                                            child: Column(
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 20.0,
                                                                      bottom:
                                                                          10.0),
                                                                  child: Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        'Ausrüstung hinzufügen',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                21,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child:
                                                                            CustomCloseButton(),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Divider(
                                                                  indent: 15,
                                                                  endIndent: 15,
                                                                  height: 1,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        CustomScrollView(
                                                                  slivers: [
                                                                    EquipmentList(
                                                                      packingPlanId:
                                                                          packingPlan
                                                                              .id,
                                                                      onItemClick:
                                                                          (equipmentId) {
                                                                        int? loc = items
                                                                            .where((element) =>
                                                                                element.equipmentId ==
                                                                                equipmentId)
                                                                            .sorted((a, b) =>
                                                                                a.location.compareTo(b.location))
                                                                            .firstOrNull
                                                                            ?.location;
                                                                        CustomDialog
                                                                            .showCustomDialog(
                                                                          barrierDismissible:
                                                                              true,
                                                                          context:
                                                                              context,
                                                                          child: EditItem(
                                                                              location: loc,
                                                                              equipmentId: equipmentId,
                                                                              packingPlan: packingPlan),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                )),
                                                              ],
                                                            )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (items.isNotEmpty)
                                          Padding(
                                            padding: Design.pagePadding,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                TooltipVisibility(
                                                  visible: false,
                                                  child: Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      splashFactory: NoSplash
                                                          .splashFactory,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      splashColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: PopupMenuButton(
                                                      color: Colors.white,
                                                      splashRadius: 100,
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      itemBuilder: (context) =>
                                                          [
                                                        CustomPopupMenuItem(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 5.0,
                                                              right: 5.0,
                                                            ),
                                                            child: TextButton(
                                                              style: TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      Design.colors[
                                                                          0],
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0))),
                                                              onPressed: () {
                                                                context.pop();
                                                                ref
                                                                    .read(dropdownIndexProvider
                                                                        .notifier)
                                                                    .state = 0;
                                                              },
                                                              child: const Text(
                                                                'Gesamt',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        for (String location
                                                            in packingPlan
                                                                .locations)
                                                          CustomPopupMenuItem(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5.0,
                                                                      right:
                                                                          5.0,
                                                                      top:
                                                                          10.0),
                                                              child: TextButton(
                                                                style: TextButton.styleFrom(
                                                                    foregroundColor:
                                                                        Design.colors[
                                                                            0],
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0))),
                                                                onPressed: () {
                                                                  context.pop();
                                                                  ref
                                                                      .read(dropdownIndexProvider
                                                                          .notifier)
                                                                      .state = packingPlan
                                                                          .locations
                                                                          .indexWhere((element) =>
                                                                              element ==
                                                                              location) +
                                                                      1;
                                                                },
                                                                child: Text(
                                                                  location,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          17),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(7.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black38),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              ref.watch(dropdownIndexProvider) ==
                                                                      0
                                                                  ? 'Gesamt'
                                                                  : packingPlan
                                                                          .locations[
                                                                      ref.watch(
                                                                              dropdownIndexProvider) -
                                                                          1],
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Design
                                                                      .colors[0]),
                                                            ),
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          8.0),
                                                              child: Icon(
                                                                Icons
                                                                    .keyboard_arrow_down_rounded,
                                                                color: Colors
                                                                    .black38,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (getCurrentStatistic()
                                                    .title
                                                    .isNotEmpty)
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.0),
                                                    child: Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                if (getCurrentStatistic()
                                                    .title
                                                    .isNotEmpty)
                                                Flexible(
                                                  child: Text(
                                                    getCurrentStatistic().title,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 17),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                                  child: Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: Colors.black38,
                                                  ),
                                                ),
                                                Text(
                                                  '${getCurrentStatistic().weight} g',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Design.colors[0],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (items.isNotEmpty)
                                          Flex(
                                            //TODO
                                            direction: Axis.vertical,
                                            /*
                                            direction: isDesktop
                                                ? Axis.horizontal
                                                : Axis.vertical,
                                                */
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                height: 400,
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    PageView.builder(
                                                      itemBuilder:
                                                          (context, index) {
                                                        Statistic statistic =
                                                            statistics[index];
                                                        return SizedBox(
                                                          height: 500,
                                                          width: 500,
                                                          child: CustomPieChart(
                                                            chartData: statistic
                                                                .chartData,
                                                            onTouchedIndexChanged:
                                                                (value) {
                                                              if (index == 0) {
                                                                Future.delayed(const Duration(
                                                                        milliseconds:
                                                                            500))
                                                                    .then(
                                                                  (result) => pageController.animateToPage(
                                                                      (value +
                                                                          1),
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                      curve: Curves
                                                                          .ease),
                                                                );
                                                              } else {
                                                                ref
                                                                    .read(pageIndexProvider
                                                                        .notifier)
                                                                    .state = [
                                                                  index,
                                                                  value
                                                                ];
                                                              }
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      itemCount:
                                                          statistics.length,
                                                      controller:
                                                          pageController,
                                                      onPageChanged: (newPage) {
                                                        ref
                                                            .read(
                                                                pageIndexProvider
                                                                    .notifier)
                                                            .state = [
                                                          newPage,
                                                          -1
                                                        ];
                                                      },
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        for (var i = 0;
                                                            i <
                                                                statistics
                                                                    .length;
                                                            i++)
                                                          Container(
                                                            width: 15,
                                                            height: 15,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5,
                                                                    right: 5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: (i ==
                                                                      ref
                                                                          .watch(
                                                                              pageIndexProvider)
                                                                          .first)
                                                                  ? Colors
                                                                      .black54
                                                                  : Colors
                                                                      .black12,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () => pageController.animateToPage(
                                                                  i,
                                                                  duration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  curve: Curves
                                                                      .ease),
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 600.0,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: getRightSection(
                                                      getCurrentStatistic()),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (items.isEmpty)
                                  const SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: Text('Füge Ausrüstung hinzu.',
                                          style:
                                              TextStyle(color: Colors.black54)),
                                    ),
                                  ),
                                SliverToBoxAdapter(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: Design.pagePadding
                                            .copyWith(top: 20.0),
                                        child: const Divider(),
                                      ),
                                      Container(
                                        margin: Design.pagePadding.copyWith(
                                            bottom: 15.0 +
                                                MediaQuery.of(context)
                                                    .padding
                                                    .bottom),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'Erstellt: ${parseDate(packingPlan.createdAt)}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                  },
                );
          }),
    );
  }
}

class Statistic {
  final String topCategory;
  final Map<String, List<PackingPlanItem>> categoryPackingPlanItemsMap;
  final WidgetRef ref;

  const Statistic(
      {required this.topCategory,
      required this.categoryPackingPlanItemsMap,
      required this.ref});

  String get title =>
      topCategory.isEmpty ? '' : Data.getCategoryNames(topCategory).last;

  double getWeight(List<PackingPlanItem>? items) {
    var result = 0.0;
    if (items != null) {
      for (PackingPlanItem item in items) {
        result = result +
            (item.equipmentCount *
                ref
                    .read(equipmentStreamProvider)
                    .value!
                    .singleWhere((element) => element.id == item.equipmentId)
                    .weight);
      }
    }
    return result;
  }

  double get weight {
    List<PackingPlanItem> allItemsList = [];
    categoryPackingPlanItemsMap.forEach((key, value) {
      allItemsList.addAll(value);
    });

    return getWeight(allItemsList);
  }

  List<ChartData> get chartData => categoryPackingPlanItemsMap.entries
      .map((entry) => ChartData(
          x: Data.getCategoryNames(entry.key).last,
          y: ((getWeight(entry.value) / weight) * 100).roundToDouble()))
      .toList();
}

class _TipCard extends StatelessWidget {
  final Tip tip;
  final bool isConditionMet;

  const _TipCard({required this.tip, required this.isConditionMet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: Design.pagePadding.copyWith(top: 10.0),
      decoration: BoxDecoration(
          color: isConditionMet ? Design.colors[1] : Design.colors[6],
          borderRadius: BorderRadius.circular(20.0)),
      child: Row(
        children: [
          Icon(
            isConditionMet ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 50.0,
            color: Colors.white,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    tip.subTitle,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
