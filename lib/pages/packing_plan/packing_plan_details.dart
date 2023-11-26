import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_back_button.dart';
import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';
import '../../validators/packing_plan_validator.dart';
import 'custom_pie_chart.dart';

class PackingPlanDetails extends ConsumerStatefulWidget {
  final String packingPlanID;

  const PackingPlanDetails({Key? key, required this.packingPlanID})
      : super(key: key);

  @override
  ConsumerState<PackingPlanDetails> createState() => _PackingPlanDetailsState();
}

class _PackingPlanDetailsState extends ConsumerState<PackingPlanDetails> {
  final dropdownIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
  final _formKey = GlobalKey<FormState>();
  final pageController = PageController(initialPage: 0);
  final pageIndexProvider = StateProvider<List<int>>((ref) => [0, -1]);

  @override
  Widget build(BuildContext context) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);
    final equipmentList = ref.watch(equipmentStreamProvider);

    return Column(
      children: [
        const CustomBackButton(),
        Expanded(
          child: equipmentList.when(
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator.adaptive(),
            data: (equipmentData) {
              return packingPlanList.when(
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => const CircularProgressIndicator.adaptive(),
                data: (packingPlanData) {
                  final PackingPlan packingPlan = packingPlanData.singleWhere(
                      (element) => element.id == widget.packingPlanID);
                  final TextEditingController controllerNotes =
                      TextEditingController(text: packingPlan.notes ?? '');

                  Statistic statisticFromItems(
                      MapEntry<String, List<PackingPlanItem>?> entry) {
                    Map<String, List<PackingPlanItem>>
                        categoryPackingPlanItemsMap = {};
                    for (PackingPlanItem i in entry.value ?? []) {
                      Equipment e = equipmentData.singleWhere(
                          (element) => element.id == i.equipmentId);
                      String topCategory =
                          e.category.substring(entry.key.length);
                      topCategory = entry.key +
                          ((topCategory.contains('.', 1))
                              ? topCategory.substring(
                                  0, topCategory.indexOf('.', 1))
                              : topCategory);

                      categoryPackingPlanItemsMap.containsKey(topCategory)
                          ? categoryPackingPlanItemsMap[topCategory]!.add(i)
                          : categoryPackingPlanItemsMap[topCategory] = [i];
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
                    statisticFromItems(MapEntry('', packingPlan.items)),
                  ];

                  for (MapEntry<String, List<PackingPlanItem>> entry
                      in statistics.first.categoryPackingPlanItemsMap.entries) {
                    statistics.add(statisticFromItems(entry));
                  }

                  List<PackingPlanItem> getPlainItemList(
                      List<PackingPlanItem> list) {
                    List<PackingPlanItem> result = list;
                    for (var element in list) {
                      if (element.items != null) {
                        getPlainItemList(element.items!).forEach((elementToInsert) {
                          int temp = result.indexWhere((e) => e.equipmentId == elementToInsert.equipmentId);
                          if(temp == -1) {
                            result.add(elementToInsert);
                          } else {
                            result[temp] = PackingPlanItem(equipmentCount: result.elementAt(temp).equipmentCount + elementToInsert.equipmentCount, items: [...?result.elementAt(temp).items, ...?elementToInsert.items], equipmentId: elementToInsert.equipmentId, isChecked: false);
                          }
                        });
                      }
                    }
                    return result;
                  }

                  List<Widget> getRightSection(Statistic statistic) {
                    var result = <Widget>[
                      Text(
                        '${statistic.title}: ${statistic.weight}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ];
                    List<PackingPlanItem> plainItemList = [];
                    for (var element
                        in statistic.categoryPackingPlanItemsMap.values) {
                      plainItemList.addAll(element);
                    }
                    plainItemList = getPlainItemList(plainItemList);

                    Statistic s = statisticFromItems(
                        MapEntry(statistic.topCategory, plainItemList));

                    ///ohne verschachtelung:
                    ///s = statistic;

                    for (MapEntry<String, List<PackingPlanItem>> entry
                        in s.categoryPackingPlanItemsMap.entries) {
                      result.add(Column(
                        children: [
                          Text(Data.getCategoryNames(entry.key).last),
                          for (PackingPlanItem item in entry.value)
                            Card(
                              child: Text(
                                  '${equipmentData.singleWhere((element) => element.id == item.equipmentId).brand} ${equipmentData.singleWhere((element) => element.id == item.equipmentId).name}@${item.equipmentCount}'),
                            ),
                        ],
                      ));
                    }
                    return result;
                  }

                  return Stack(children: [
                    ListView(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Text(packingPlan.name),
                              Text(packingPlan.createdAt.toString()),
                              Text(packingPlan.updatedAt.toString()),
                              Text('notes: ${packingPlan.notes}'),
                              for (var sport in packingPlan.sports) Text(sport),
                              ElevatedButton(
                                  onPressed: () {
                                    context.push('/packing_plan/edit',
                                        extra: packingPlan);
                                  },
                                  child: const Text('edit')),
                              ElevatedButton(
                                  onPressed: () async {
                                    bool? confirmDelete = await CustomDialog
                                        .showCustomConfirmationDialog(
                                            context: context,
                                            description: "Wirklich löschen?");
                                    if (confirmDelete ?? false) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(Auth().user?.uid)
                                          .collection('packing_plan')
                                          .doc(packingPlan.id)
                                          .delete()
                                          .then((value) => context.pop());
                                    }
                                  },
                                  child: const Text('delete')),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              DropdownButton(
                                items: const [
                                  DropdownMenuItem(
                                      value: 0, child: Text('total')),
                                  DropdownMenuItem(
                                      value: 1, child: Text('body')),
                                  DropdownMenuItem(
                                      value: 2, child: Text('backpack')),
                                ],
                                onChanged: (value) {
                                  ref
                                      .read(dropdownIndexProvider.notifier)
                                      .state = value ?? 0;
                                },
                                value: ref.watch(dropdownIndexProvider),
                              ),
                              SizedBox(
                                height: 550,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Stack(children: [
                                        PageView.builder(
                                          itemBuilder: (context, index) {
                                            Statistic statistic =
                                                statistics[index];
                                            return SizedBox(
                                              height: 500,
                                              width: 500,
                                              child: CustomPieChart(
                                                chartData: statistic.chartData,
                                                onTouchedIndexChanged: (value) {
                                                  if (index == 0) {
                                                    Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    500))
                                                        .then(
                                                      (result) => pageController
                                                          .animateToPage(
                                                              (value + 1),
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                              curve:
                                                                  Curves.ease),
                                                    );
                                                  } else {
                                                    ref
                                                        .read(pageIndexProvider
                                                            .notifier)
                                                        .state = [index, value];
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                          itemCount: statistics.length,
                                          controller: pageController,
                                          onPageChanged: (newPage) {
                                            ref
                                                .read(
                                                    pageIndexProvider.notifier)
                                                .state = [newPage, -1];
                                          },
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              for (var i = 0;
                                                  i < statistics.length;
                                                  i++)
                                                Container(
                                                  width: 15,
                                                  height: 15,
                                                  margin: const EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  decoration: BoxDecoration(
                                                    color: (i ==
                                                            ref
                                                                .watch(
                                                                    pageIndexProvider)
                                                                .first)
                                                        ? Colors.blue
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
                                                            curve: Curves.ease),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.black12,
                                        width: 400,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: getRightSection((ref
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
                                                  .first]),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) =>
                                  PackingPlanValidator.notes(value),
                              controller: controllerNotes,
                              decoration:
                                  const InputDecoration(labelText: 'Notizen'),
                              minLines: 6,
                              maxLines: 6,
                              keyboardType: TextInputType.multiline,
                              onTapOutside: (value) {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  DocumentReference ref = FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(Auth().user?.uid)
                                      .collection('packing_plan')
                                      .doc(packingPlan.id);

                                  ref.update({"notes": controllerNotes.text});
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ElevatedButton(
                              child: const Icon(Icons.lightbulb_rounded),
                              onPressed: () {
                                const dialogContent = Text('tipps');
                                CustomDialog.showCustomModal(
                                    context, dialogContent);
                              },
                            ),
                          ),
                          ElevatedButton(
                            child: const Row(
                              children: [
                                Icon(Icons.add),
                                Text('item'),
                              ],
                            ),
                            onPressed: () {
                              const dialogContent = Text('add item to plan');
                              CustomDialog.showCustomModal(
                                  context, dialogContent);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                },
              );
            },
          ),
        ),
      ],
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
      ? 'total weight'
      : 'weight ${Data.getCategoryNames(topCategory).last}';

  double getWeight(List<PackingPlanItem>? items) {
    if (items == null) return 0.0;
    var result = 0.0;
    for (PackingPlanItem item in items) {
      result = result +
          (item.equipmentCount *
              ref
                  .read(equipmentStreamProvider)
                  .value!
                  .singleWhere((element) => element.id == item.equipmentId)
                  .weight);
      result = result + getWeight(item.items);
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
