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
import 'package:equipment_app/pages/packing_plan/details/item_list.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_edit.dart';
import 'package:equipment_app/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../custom_widgets/custom_dialog.dart';
import '../../../custom_widgets/popupitem_extension.dart';
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
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ref.watch(equipmentStreamProvider).when(
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => _loading,
          data: (equipmentList) {
            return ref.watch(packingPlanStreamProvider).when(
                  error: (error, stackTrace) => Text(error.toString()),
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
                          error: (error, stackTrace) => Text(error.toString()),
                          loading: () => _loading,
                          data: (items) {
                            final TextEditingController controllerNotes =
                                TextEditingController(
                                    text: packingPlan.notes ?? '');

                            Future<void> editItem(
                                {required String equipmentId,
                                required bool allowSelectLocation,
                                int? location}) async {
                              CustomDialog.showCustomDialog(
                                context: context,
                                child: EditItem(
                                    allowSelectLocation: allowSelectLocation,
                                    location: location,
                                    equipmentId: equipmentId,
                                    packingPlan: packingPlan),
                              );
                            }

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
                              statistics.add(statisticFromItems(entry));
                            }

                            List<Widget> getRightSection(Statistic statistic) {
                              var result = <Widget>[
                                Text(statistic.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ];

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
                                result.add(Column(
                                  children: [
                                    Text(Data.getCategoryNames(entry.key).last),
                                    for (PackingPlanItem item in entry.value)
                                      Card(
                                        child: Text(
                                            '${equipmentList.singleWhere((element) => element.id == item.equipmentId).brand} ${equipmentList.singleWhere((element) => element.id == item.equipmentId).name}@${item.equipmentCount}'),
                                      ),
                                  ],
                                ));
                              }
                              return result;
                            }

                            Statistic getCurrentStatistic () {
                              return (ref
                                  .watch(
                                  pageIndexProvider)
                                  .last !=
                                  -1 &&
                                  statistics[ref.watch(pageIndexProvider).first]
                                      .categoryPackingPlanItemsMap
                                      .entries
                                      .length >
                                      1)
                                  ? statisticFromItems(MapEntry(
                                  statistics[ref.read(pageIndexProvider).first]
                                      .categoryPackingPlanItemsMap
                                      .entries
                                      .elementAt(ref
                                      .watch(
                                      pageIndexProvider)
                                      .last)
                                      .key,
                                  statistics[ref.read(pageIndexProvider).first]
                                      .categoryPackingPlanItemsMap
                                      .entries
                                      .elementAt(ref
                                      .watch(
                                      pageIndexProvider)
                                      .last)
                                      .value))
                                  : statistics[ref
                                  .read(pageIndexProvider)
                                  .first];
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
                                  padding: Design.pagePadding,
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate(
                                      [
                                        Flex(
                                          direction: isDesktop
                                              ? Axis.horizontal
                                              : Axis.vertical,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    'erstellt: ${parseDate(packingPlan.createdAt)}'),
                                                Text(
                                                    'aktualisiert: ${parseDate(packingPlan.updatedAt)}'),
                                                for (var sport
                                                    in packingPlan.sports)
                                                  Text(sport),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 300,
                                              child: Form(
                                                key: _formKey,
                                                child: TextFormField(
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
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              child: const Icon(
                                                  Icons.lightbulb_rounded),
                                              onPressed: () {
                                                const dialogContent =
                                                    Text('tipps');
                                                CustomDialog.showCustomModal(
                                                    context: context,
                                                    child: dialogContent);
                                              },
                                            ),
                                            ElevatedButton(
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.add),
                                                  Text('item'),
                                                ],
                                              ),
                                              onPressed: () =>
                                                  CustomDialog.showCustomModal(
                                                      context: context,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 5.0,
                                                                    top: 20.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child:
                                                                  CustomCloseButton(),
                                                            ),
                                                          ),
                                                          const Text(
                                                              'Ausrüstung hinzufügen'),
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
                                                                          element
                                                                              .equipmentId ==
                                                                          equipmentId)
                                                                      .sorted((a, b) => a
                                                                          .location
                                                                          .compareTo(
                                                                              b.location))
                                                                      .firstOrNull
                                                                      ?.location;
                                                                  editItem(
                                                                      equipmentId:
                                                                          equipmentId,
                                                                      location:
                                                                          loc,
                                                                      allowSelectLocation:
                                                                          true);
                                                                },
                                                              ),
                                                            ],
                                                          )),
                                                        ],
                                                      )),
                                            ),
                                            ElevatedButton(
                                              child: const Icon(Icons
                                                  .library_add_check_outlined),
                                              onPressed: () =>
                                                  CustomDialog.showCustomModal(
                                                context: context,
                                                child: ItemList(
                                                  locations:
                                                      packingPlan.locations,
                                                  packingPlanId: packingPlan.id,
                                                  onEdit: (equipmentId,
                                                          location) =>
                                                      editItem(
                                                          equipmentId:
                                                              equipmentId,
                                                          location: location,
                                                          allowSelectLocation:
                                                              false),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TooltipVisibility(
                                              visible: false,
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  splashFactory: NoSplash.splashFactory,
                                                  highlightColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                ),
                                                child: PopupMenuButton(
                                                  color: Colors.white,
                                                  splashRadius: 100,
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
                                                              ref
                                                                  .read(dropdownIndexProvider
                                                                  .notifier)
                                                                  .state = 0;
                                                            },
                                                            child: const Text('Gesamt'),

                                                          ),
                                                        ),
                                                    ),
                                                    for (String location
                                                    in packingPlan.locations)
                                                    CustomPopupMenuItem(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              left: 5.0,
                                                              right: 5.0,
                                                              top: 10.0),
                                                          child: TextButton(
                                                            style: TextButton.styleFrom(
                                                                foregroundColor: Design.colors[0],
                                                                shape:
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        10.0))),
                                                            onPressed: () {
                                                              context.pop();
                                                              ref
                                                                  .read(dropdownIndexProvider
                                                                  .notifier)
                                                                  .state = packingPlan.locations.indexWhere((element) => element == location) + 1;
                                                            },
                                                            child: Text(location),
                                                          ),
                                                        ),
                                                    ),
                                                  ],
                                                  child: Text(ref.watch(dropdownIndexProvider) == 0 ? 'Gesamt' : packingPlan.locations[ref.watch(dropdownIndexProvider) - 1], style: const TextStyle(fontSize: 17),),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                child: Icon(Icons.chevron_right_rounded, color: Colors.black38,),
                                            ),
                                            Text(getCurrentStatistic().title, style: const TextStyle(color: Colors.black54, fontSize: 17),),
                                            if(getCurrentStatistic().title.isNotEmpty)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Icon(Icons.chevron_right_rounded, color: Colors.black38,),
                                            ),
                                            Text('${getCurrentStatistic().weight} g',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Flex(
                                          direction: isDesktop ? Axis.horizontal : Axis.vertical,
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 400,
                                                child: Stack(
                                                  alignment: Alignment.bottomCenter,
                                                  children: [
                                                    PageView.builder(
                                                      itemBuilder: (context, index) {
                                                        Statistic statistic =
                                                            statistics[index];
                                                        return SizedBox(
                                                          height: 500,
                                                          width: 500,
                                                          child: CustomPieChart(
                                                            chartData:
                                                                statistic.chartData,
                                                            onTouchedIndexChanged:
                                                                (value) {
                                                              if (index == 0) {
                                                                Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                500))
                                                                    .then(
                                                                  (result) => pageController
                                                                      .animateToPage(
                                                                          (value + 1),
                                                                          duration: const Duration(
                                                                              milliseconds:
                                                                                  500),
                                                                          curve: Curves
                                                                              .ease),
                                                                );
                                                              } else {
                                                                ref
                                                                    .read(
                                                                        pageIndexProvider
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
                                                      itemCount: statistics.length,
                                                      controller: pageController,
                                                      onPageChanged: (newPage) {
                                                        ref
                                                            .read(pageIndexProvider
                                                                .notifier)
                                                            .state = [newPage, -1];
                                                      },
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: [
                                                        for (var i = 0;
                                                            i < statistics.length;
                                                            i++)
                                                          Container(
                                                            width: 15,
                                                            height: 15,
                                                            margin:
                                                                const EdgeInsets.only(
                                                                    left: 5,
                                                                    right: 5),
                                                            decoration: BoxDecoration(
                                                              color: (i ==
                                                                      ref
                                                                          .watch(
                                                                              pageIndexProvider)
                                                                          .first)
                                                                  ? Colors.black54
                                                                  : Colors.black12,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: GestureDetector(
                                                              onTap: () => pageController
                                                                  .animateToPage(i,
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
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.black12,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: getRightSection(getCurrentStatistic()),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
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

  String get title => topCategory.isEmpty
      ? ''
      : Data.getCategoryNames(topCategory).last;

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
