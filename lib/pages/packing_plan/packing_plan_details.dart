import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
      List<ChartData> chartData = <ChartData>[
        ChartData(x: 'Bekleidung', y: 13),
        ChartData(x: 'Ausrüstung', y: 24),
        ChartData(x: 'Verpflegung', y: 25),
        ChartData(x: 'Sonstiges', y: 38),
      ];
      return Card(
        child: Column(
          children: [
            Text('total weight: $weight'),
            SfCircularChart(
              series: getPieSeries(chartData: chartData),
            ),
            Column(
                children: [
                  const Text('Gegenstände'),
                  Row(
                    children: [
                      for (PackingPlanItem item
                      in items ?? [])
                        Card(
                          child: Text(equipmentList!
                              .singleWhere((element) =>
                          element.id == item.equipmentId)
                              .name),
                        ),
                    ],
                  )
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

List<PieSeries<ChartData, String>> getPieSeries(
    {required List<ChartData> chartData}) {
  return <PieSeries<ChartData, String>>[
    PieSeries<ChartData, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        dataLabelMapper: (ChartData data, _) => data.text,
        startAngle: 90,
        endAngle: 90,
        radius: '150',
        dataLabelSettings: const DataLabelSettings(isVisible: true))
  ];
}

class ChartData {
  final String x;
  final double y;
  late final String text;

  ChartData({required this.x, required this.y}) {
    text = '$x\n$y%';
  }
}
