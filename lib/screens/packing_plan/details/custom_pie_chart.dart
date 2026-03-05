import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/models/packing_plan_details_data.dart';
import 'package:bergdinge/screens/packing_plan/details/analysis.dart';
import 'package:bergdinge/models/statistic.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomPieChart extends ConsumerStatefulWidget {
  final PackingPlanDetailsData data;

  const CustomPieChart({super.key, required this.data});

  @override
  ConsumerState<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends ConsumerState<CustomPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final statisticStack = ref.watch(statisticProvider);
    List<PieChartSectionData> sectionData() {
      final statistic = (statisticStack.length == 1 ||
              statisticStack.last.canBuildChildStatistic)
          ? statisticStack.last
          : statisticStack.elementAt(statisticStack.length - 2);

      return statistic.chartData(widget.data.equipment).mapIndexed((i, e) {
        final isTouched = touchedIndex == i ||
            (touchedIndex == null &&
                (statistic == statisticStack.last ||
                    statisticStack.last.parentCategory.startsWith(e.category)));
        return PieChartSectionData(
          color: Design.getSectionColor(
                  colorSection: e.rootCategory,
                  index: statistic == statisticStack.first ? 0 : i)
              .withValues(alpha: isTouched ? 1.0 : 0.2),
          value: e.value,
          showTitle: false,
          radius: 30.0,
        );
      }).toList();
    }

    return PieChart(
      PieChartData(
        sections: sectionData(),
        centerSpaceRadius: 100,
        sectionsSpace: 3,
        pieTouchData: PieTouchData(
          longPressDuration: const Duration(seconds: 2),
          touchCallback: (FlTouchEvent event, pieTouchResponse) async {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null ||
                event.runtimeType != FlTapDownEvent) {
              return;
            }
            final touched =
                pieTouchResponse.touchedSection!.touchedSectionIndex;

            if (touched == -1 || !statisticStack.last.canBuildChildStatistic) {
              if (statisticStack.length > 1) {
                ref.read(statisticProvider.notifier).pop();
              }
            } else {
              final mapEntry = statisticStack.last.entryFromIndex(touched);
              final newStatistic = Statistic(
                  items: mapEntry.value,
                  equipmentList: widget.data.equipment,
                  parentCategory: mapEntry.key);

              setState(() {
                if (newStatistic.canBuildChildStatistic) touchedIndex = touched;
              });
              await Future.delayed(Duration(milliseconds: 300));
              ref.read(statisticProvider.notifier).push(newStatistic);
              setState(() {
                touchedIndex = null;
              });
            }
          },
        ),
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
    );
  }
}

class ChartData {
  final int rootCategory;
  final String category;
  final double value;

  ChartData(
      {required this.rootCategory,
      required this.value,
      required this.category});
}
