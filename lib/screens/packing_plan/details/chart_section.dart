import 'package:bergdinge/models/packing_plan_details_data.dart';
import 'package:bergdinge/models/packing_plan_location.dart';
import 'package:bergdinge/screens/packing_plan/details/analysis.dart';
import 'package:bergdinge/utilities/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/design.dart';
import 'custom_pie_chart.dart';

class ChartSection extends ConsumerWidget {
  final PackingPlanLocation? locationSource;
  final PackingPlanDetailsData data;

  const ChartSection({super.key, this.locationSource, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticStack = ref.watch(statisticProvider);
    if (statisticStack.isEmpty) return Container();
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 300,
          width: 300,
          child: statisticStack.last.categoryItemsMap.isEmpty
              ? null
              : CustomPieChart(data: data,),
        ),
        GestureDetector(
          onTap: () {
            if (statisticStack.length > 1) {
              ref.read(statisticProvider.notifier).pop();
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: 200.0,
            width: 200.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${Parser.thousandDot(statisticStack.last.weight(data.equipment))} g',
                  style: TextStyle(
                      fontSize: 22,
                      color: Design.darkGreen,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    statisticStack.last.title.isNotEmpty
                        ? statisticStack.last.title
                        : locationSource == null
                            ? 'Gesamt'
                            : locationSource!.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (statisticStack.length > 1)
          Positioned(
              bottom: 60,
              child: IconButton(
                onPressed: () {
                  ref.read(statisticProvider.notifier).pop();
                },
                icon: const Icon(
                  CupertinoIcons.clear_circled,
                  color: Colors.black54,
                  size: 40.0,
                ),
              )),
      ],
    );
  }
}
