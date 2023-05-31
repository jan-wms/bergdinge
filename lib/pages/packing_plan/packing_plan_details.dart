import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../custom_widgets/custom_back_button.dart';
import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';
import '../../data_models/equipment.dart';

class PackingPlanDetails extends ConsumerWidget {
  final String packingPlanID;

  const PackingPlanDetails({Key? key, required this.packingPlanID})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              final PackingPlan packingPlan = data.singleWhere((element) => element.id == packingPlanID);
              List<Equipment> items = [];
              for (var element in packingPlan.items) {
                items.add(equipmentList!.singleWhere((e) => e.id == element.equipmentId));
              }

              var totalWeight = 0.0;
              for (var element in packingPlan.items) {
                var item = equipmentList?.singleWhere((e) => e.id == element.equipmentId);
                totalWeight = totalWeight + (element.equipmentCount * item!.weight);
              }

              return ListView(
                children: [
                  Text(packingPlan.name),
                  Text('total weight: $totalWeight'),
                  for (var sport in packingPlan.sports) Text(sport),
                  for (var item in packingPlan.items) Text(item.equipmentId),
                  SfCircularChart(
                    series: getDefaultPieSeries(),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        bool? confirmDelete =
                            await CustomDialog.showCustomConfirmationDialog(
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
                  ElevatedButton(
                      onPressed: () {
                        context.push('/packing_plan/edit', extra: packingPlan);
                      },
                      child: const Text('edit')),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

List<PieSeries<ChartSampleData, String>> getDefaultPieSeries() {
  return <PieSeries<ChartSampleData, String>>[
    PieSeries<ChartSampleData, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        dataSource: <ChartSampleData>[
          ChartSampleData(x: 'David', y: 13, text: 'David \n 13%'),
          ChartSampleData(x: 'Steve', y: 24, text: 'Steve \n 24%'),
          ChartSampleData(x: 'Jack', y: 25, text: 'Jack \n 25%'),
          ChartSampleData(x: 'Others', y: 38, text: 'Others \n 38%'),
        ],
        xValueMapper: (ChartSampleData data, _) => data.x,
        yValueMapper: (ChartSampleData data, _) => data.y,
        dataLabelMapper: (ChartSampleData data, _) => data.text,
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: const DataLabelSettings(isVisible: true)),
  ];
}

class ChartSampleData {
  final String x;
  final double y;
  final String text;

  ChartSampleData({required this.x, required this.y, required this.text});
}