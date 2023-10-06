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

  @override
  Widget build(BuildContext context) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);
    final equipmentList = ref.watch(equipmentStreamProvider).value;

    return Column(
      children: [
        const CustomBackButton(),
        Expanded(
          child: packingPlanList.when(
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator.adaptive(),
            data: (data) {
              final PackingPlan packingPlan = data
                  .singleWhere((element) => element.id == widget.packingPlanID);
              final TextEditingController controllerNotes =
                  TextEditingController(text: packingPlan.notes ?? '');

              Statistic statisticFromItems(
                  MapEntry<String, List<PackingPlanItem>?> entry) {
                Map<String, List<PackingPlanItem>> categoryPackingPlanItemsMap =
                    {};
                for (PackingPlanItem i in entry.value ?? []) {
                  Equipment e = equipmentList!
                      .singleWhere((element) => element.id == i.equipmentId);
                  String topCategory = e.category.substring(entry.key.length);
                  topCategory = entry.key +
                      ((topCategory.contains('.', 1))
                          ? topCategory.substring(
                              0, topCategory.indexOf('.', 1))
                          : topCategory);

                  categoryPackingPlanItemsMap.containsKey(topCategory)
                      ? categoryPackingPlanItemsMap[topCategory]!.add(i)
                      : categoryPackingPlanItemsMap[topCategory] = [i];
                }

                return Statistic(
                    topCategory: entry.key,
                    categoryPackingPlanItemsMap: categoryPackingPlanItemsMap,
                    ref: ref);
              }

              List<Statistic> statistics = [
                statisticFromItems(MapEntry('', packingPlan.items)),
              ];

              for (MapEntry<String, List<PackingPlanItem>> entry
                  in statistics.first.categoryPackingPlanItemsMap.entries) {
                statistics.add(statisticFromItems(entry));
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
                              DropdownMenuItem(value: 0, child: Text('total')),
                              DropdownMenuItem(value: 1, child: Text('body')),
                              DropdownMenuItem(
                                  value: 2, child: Text('backpack')),
                            ],
                            onChanged: (value) {
                              ref.read(dropdownIndexProvider.notifier).state =
                                  value ?? 0;
                            },
                            value: ref.watch(dropdownIndexProvider),
                          ),
                          SizedBox(
                            height: 550,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Stack(children: [
                                    PageView.builder(
                                      itemBuilder: (context, index) {
                                        Statistic statistic = statistics[index];
                                        return Column(
                                          children: [
                                            Text(
                                                '${statistic.title}: ${statistic.weight}'),
                                            SizedBox(
                                              height: 500,
                                              width: 500,
                                              child: CustomPieChart(
                                                chartData: statistic.chartData,
                                                onTouchedIndexChanged: (value) {
                                                  print('new value$value');
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      itemCount: statistics.length,
                                      controller: pageController,
                                    ),
                                    //TODO dot indicator
                                    Positioned(
                                      bottom: 20,
                                      left: 0,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ]),
                                ),
                                Container(
                                  color: Colors.black12,
                                  width: 400,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Gegenstände total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      for (MapEntry<String,
                                              List<PackingPlanItem>> entry
                                          in statistics
                                              .first
                                              .categoryPackingPlanItemsMap
                                              .entries)
                                        Column(
                                          children: [
                                            Text(
                                                Data.getCategoryNames(entry.key)
                                                    .last),
                                            for (PackingPlanItem item
                                                in entry.value)
                                              Card(
                                                child: Text(
                                                    '${equipmentList!.singleWhere((element) => element.id == item.equipmentId).name}@${item.equipmentCount}'),
                                              ),
                                          ],
                                        ),
                                    ],
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
                              DocumentReference ref = FirebaseFirestore.instance
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
                  child: ElevatedButton(
                    child: const Row(
                      children: [
                        Icon(Icons.add),
                        Text('item'),
                      ],
                    ),
                    onPressed: () {
                      const dialogContent = Text('add item to plan');
                      CustomDialog.showCustomModal(context, dialogContent);
                    },
                  ),
                ),
              ]);
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

  String get title => topCategory.isEmpty ? 'total weight' : 'weight ${Data.getCategoryNames(topCategory).last}';

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
          y: getWeight(entry.value) / weight))
      .toList();
}
