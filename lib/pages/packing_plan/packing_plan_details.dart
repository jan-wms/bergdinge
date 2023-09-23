import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../custom_widgets/custom_back_button.dart';
import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';
import '../../validators/packing_plan_validator.dart';

class PackingPlanDetails extends ConsumerStatefulWidget {
  final String packingPlanID;

  const PackingPlanDetails({Key? key, required this.packingPlanID})
      : super(key: key);

  @override
  ConsumerState<PackingPlanDetails> createState() => _PackingPlanDetailsState();
}

class _PackingPlanDetailsState extends ConsumerState<PackingPlanDetails> {
  final dropdownValueProvider = StateProvider<int>((ref) => 0);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);
    final equipmentList = ref.watch(equipmentStreamProvider).value;

    double getWeight(List<PackingPlanItem>? items) {
      if (items == null) return 0.0;
      var result = 0.0;
      for (PackingPlanItem item in items) {
        result = result +
            (item.equipmentCount *
                equipmentList!
                    .singleWhere((element) => element.id == item.equipmentId)
                    .weight);
        result = result + getWeight(item.items);
      }
      return result;
    }

    Widget getStatistics({required List<PackingPlanItem>? items}) {
      double weight = getWeight(items);

      Map<String, List<PackingPlanItem>>? categoryPackingPlanItemsMap = {};
      for (PackingPlanItem i in items ?? []) {
        Equipment e = equipmentList!
            .singleWhere((element) => element.id == i.equipmentId);
        String key = e.category.substring(0, e.category.indexOf('.'));
        categoryPackingPlanItemsMap.containsKey(key)
            ? categoryPackingPlanItemsMap[key]!.add(i)
            : categoryPackingPlanItemsMap[key] = [i];
      }

      List<ChartData> chartData = categoryPackingPlanItemsMap.entries
          .map((entry) => ChartData(
              x: Data.getCategoryNames(entry.key).last,
              y: getWeight(entry.value) / weight))
          .toList();


      return Card(
        child: Column(
          children: [
            Text('total weight: $weight'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 500,
                  width: 500,
                    child: PieChart(
                      getPieChartData(chartData: chartData),
                      swapAnimationDuration: const Duration(milliseconds: 150),
                      // Optional
                      swapAnimationCurve: Curves.linear, // Optional
                    ),
                ),
                Column(
                  children: [
                    const Text('Gegenstände total', style: TextStyle(fontWeight: FontWeight.bold),),
                    for (MapEntry<String, List<PackingPlanItem>> entry
                        in categoryPackingPlanItemsMap.entries)
                      Column(
                        children: [
                          Text(Data.getCategoryNames(entry.key).last),
                          for (PackingPlanItem item in entry.value)
                            Card(
                              child: Text(
                                  '${equipmentList!.singleWhere((element) => element.id == item.equipmentId).name}@${item.equipmentCount}'),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

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

              return ListView(
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
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) => PackingPlanValidator.notes(value),
                        controller: controllerNotes,
                        decoration: const InputDecoration(labelText: 'Notizen'),
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
                  DropdownButton(
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('total')),
                      DropdownMenuItem(value: 1, child: Text('body')),
                      DropdownMenuItem(value: 2, child: Text('backpack')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        ref.read(dropdownValueProvider.notifier).state =
                            value ?? 0;
                      });
                    },
                    value: ref.watch(dropdownValueProvider),
                  ),
                  getStatistics(items: packingPlan.items),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

PieChartData getPieChartData({required List<ChartData> chartData}) {
  final isTouched = false;//i == touchedIndex;
  final fontSize = isTouched ? 20.0 : 16.0;
  final radius = isTouched ? 110.0 : 100.0;
  final widgetSize = isTouched ? 55.0 : 40.0;
  final titleStyle = TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
  );
  List<Color> sectionColor = [Colors.blueAccent,Colors.lightBlueAccent,Colors.blueGrey,Colors.lightBlue,Colors.blue,];
  List<Color> textColor = [Colors.white,Colors.white,Colors.white,Colors.white,Colors.white,];

  List<PieChartSectionData> sectionData = chartData.asMap().entries.map((e) {
    return PieChartSectionData(
      color: sectionColor[e.key],
      value: e.value.y,
      title: e.value.text,
      radius: radius,
      titleStyle: titleStyle.copyWith(color: textColor[e.key]),
    );
  }).toList();

  int touchedIndex = -1;
  return PieChartData(
    sections: sectionData,
    centerSpaceRadius: 0,
    sectionsSpace: 0,
    pieTouchData: PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
          if (!event.isInterestedForInteractions ||
              pieTouchResponse == null ||
              pieTouchResponse.touchedSection == null) {
            print('-1');
            return;
          }
         print(pieTouchResponse.touchedSection!.touchedSectionIndex);
      },
    ),
  );
}

class ChartData {
  final String x;
  final double y;
  late final String text;

  ChartData({required this.x, required this.y}) {
    text = '$x\n$y%';
  }
}
