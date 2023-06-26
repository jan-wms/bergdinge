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

class PackingPlanDetails extends ConsumerWidget {
  final String packingPlanID;

  const PackingPlanDetails({Key? key, required this.packingPlanID})
      : super(key: key);

  Widget getStatistics({required PackingPlan packingPlan}) {
    double weight = 1.0;
    return Column(
      children: [
        Text('total weight: $weight'),
        SfCircularChart(
          series: getDefaultPieSeries(),
        ),
      ],
    );
  }

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
              final PackingPlan packingPlan =
                  data.singleWhere((element) => element.id == packingPlanID);
              return Column(
                children: [
                  Text(packingPlan.name!),
                  Text(packingPlan.createdAt!.toString()),
                  Text(packingPlan.updatedAt!.toString()),
                  for (var sport in packingPlan.sports!) Text(sport),
                  ElevatedButton(
                      onPressed: () {
                        context.push('/packing_plan/edit', extra: packingPlan);
                      },
                      child: const Text('edit')),
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
                  DropdownButton(
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('total')),
                      DropdownMenuItem(value: 1, child: Text('body')),
                      DropdownMenuItem(value: 2, child: Text('backpack')),
                    ],
                    onChanged: (value) {},
                  ),
                  getStatistics(packingPlan: packingPlan),
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
        dataLabelSettings: const DataLabelSettings(isVisible: true))
  ];
}

class ChartSampleData {
  final String x;
  final double y;
  final String text;

  ChartSampleData({required this.x, required this.y, required this.text});
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
