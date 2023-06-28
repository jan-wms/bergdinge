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

class PackingPlanDetails extends ConsumerStatefulWidget {
  final String packingPlanID;

  const PackingPlanDetails({Key? key, required this.packingPlanID}) : super(key: key);

  @override
  ConsumerState<PackingPlanDetails> createState() => _PackingPlanDetailsState();
}

class _PackingPlanDetailsState extends ConsumerState<PackingPlanDetails> {
  int dropdownValue = 0;

  Widget getStatistics({required PackingPlan packingPlan}) {
    double weight = 1.0;
    List<ChartData> chartData = <ChartData>[
      ChartData(x: 'Bekleidung', y: 13),
      ChartData(x: 'Ausrüstung', y: 24),
      ChartData(x: 'Verpflegung', y: 25),
      ChartData(x: 'Others', y: 38),
    ];
    return Card(child: Column(
      children: [
        Text('total weight: $weight'),
        SfCircularChart(
          series: getPieSeries(chartData: chartData),
        ),
      ],
    ),);
  }

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
              final PackingPlan packingPlan =
                  data.singleWhere((element) => element.id == widget.packingPlanID);
              return Column(
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
                  DropdownButton(
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('total')),
                      DropdownMenuItem(value: 1, child: Text('body')),
                      DropdownMenuItem(value: 2, child: Text('backpack')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value ?? dropdownValue;
                      });
                    },
                    value: dropdownValue,
                  ),
                  getStatistics(packingPlan: packingPlan),
                  Card(
                    child: Column(
                      children: [
                        const Text('Gegenstände'),
                        Row(
                          children: [
                            for(PackingPlanItem item in packingPlan.items ?? [])
                              Card(child: Text(equipmentList!.singleWhere((element) => element.id == item.equipmentId).name),),
                          ],
                        )
                      ],
                    ),
                  ),
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

/* @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomBackButton(),
            Text(
                'Packliste ${widget.packingPlan != null
                    ? 'bearbeiten'
                    : 'erstellen'}'),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && !isLoading) {
                    edit(
                        packingPlanList:
                        ref
                            .read(packingPlanStreamProvider)
                            .value);
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : Text(
                    widget.packingPlan != null ? 'Bearbeiten' : 'Erstellen')),
          ],
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => PackingPlanValidator.name(value),
                controller: _controllerName,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              FormField<List<String>>(
                validator: (value) => PackingPlanValidator.sports(value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKeySports,
                initialValue: widget.packingPlan?.sports ?? <String>[],
                builder: (state) =>
                    ListTile(
                      title: Text(state.value!.isNotEmpty
                          ? state.value!.toString()
                          : 'Sportart'),
                      subtitle: Text(state.errorText ?? 'Kein Fehler'),
                      trailing: const Icon(Icons.chevron_right_outlined),
                      onTap: () async {
                        final List<String> s =
                        await selectSports(context, state.value!);
                        state.didChange(s);
                      },
                    ),
              ),
              FormField<List<PackingPlan>>(
                key: _formKeyItems,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => PackingPlanValidator.items(value),
                initialValue: widget.packingPlan?.items ?? <PackingPlan>[],
                builder: (state) =>
                    ListTile(
                      onTap: () async {
                        final List<PackingPlan> i =
                        await selectEquipment(context, state.value!);
                        state.didChange(i);
                      },
                      trailing: const Icon(Icons.chevron_right_outlined),
                      title: const Text('Add item'),
                      subtitle: Text(state.errorText ?? state.value.toString()),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
Future<List<PackingPlan>> selectEquipment(BuildContext context,
    List<PackingPlan> selected) async {
  final GlobalKey<_SelectEquipmentState> k = GlobalKey();
  final SelectEquipment selectEquipment = SelectEquipment(
    key: k,
    selected: selected,
  );
  await CustomDialog.showCustomModal(
    context,
    selectEquipment,
    null,
    TextButton(
      child: const Text('Close'),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
  return k.currentState!.selected;
}

class SelectEquipment extends ConsumerStatefulWidget {
  final List<PackingPlan> selected;

  const SelectEquipment({Key? key, required this.selected}) : super(key: key);

  @override
  ConsumerState<SelectEquipment> createState() => _SelectEquipmentState();
}

class _SelectEquipmentState extends ConsumerState<SelectEquipment> {
  late List<PackingPlan> selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ausrüstung'),
        const TextField(),
        Expanded(
          child: ref.watch(equipmentStreamProvider).when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) =>
                  ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final equipment = data[index];
                      return ListTile(
                        title: Text((equipment.brand ?? '') + equipment.name),
                        subtitle: Text(equipment.size.toString()),
                        trailing: selected
                            .where((element) =>
                        element.equipmentId == equipment.id)
                            .isNotEmpty
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          if (selected
                              .where((element) =>
                          element.equipmentId == equipment.id)
                              .isNotEmpty) {
                            setState(() {
                              selected.removeWhere((element) =>
                              element.equipmentId == equipment.id);
                            });
                          } else {
                            setState(() {
                              selected.add(PackingPlan(
                                  id:,
                                  items:,
                                  sports:,
                                  equipmentId: equipment.id,
                                  equipmentCount: 1,
                                  name: null,
                              ));
                            });
                          }
                        },
                      );
                    },
                  )),
        ),
      ],
    );
  }
}
*/
