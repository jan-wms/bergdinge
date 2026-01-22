import 'package:bergdinge/data/design.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'packing_plan_details.dart';

class CustomPieChart extends ConsumerStatefulWidget {
  final List<ChartData> chartData;

  const CustomPieChart({
    super.key,
    required this.chartData,
  });

  @override
  ConsumerState<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends ConsumerState<CustomPieChart> {
  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sectionData =
        widget.chartData.asMap().entries.map((e) {
      final isTouched = e.key == ref.watch(chartIndexProvider)[1];
      return PieChartSectionData(
        color: Design.getSectionColor(
                category: ref.watch(chartIndexProvider)[0] - 1, index: e.key)
            .withValues(alpha: isTouched || ref.watch(chartIndexProvider)[1] == -1
                ? 1.0
                : 0.2),
        value: e.value.y,
        showTitle: false,
        radius: 30.0,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sectionData,
        centerSpaceRadius: 100,
        sectionsSpace: 3,
        pieTouchData: PieTouchData(
          longPressDuration: const Duration(seconds: 2),
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null ||
                event.runtimeType != FlTapDownEvent) {
              return;
            }
            final touched =
                pieTouchResponse.touchedSection!.touchedSectionIndex;

            if (touched == -1 && ref.watch(chartIndexProvider)[1] == -1) {
              return;
            }

            var newIndex =
                (ref.watch(chartIndexProvider)[1] == touched) ? -1 : touched;

            if (ref.watch(chartIndexProvider)[0] == 0) {
              ref.read(chartIndexProvider.notifier).state = [0, newIndex];
              Future.delayed(const Duration(milliseconds: 700), () {
                ref.read(chartIndexProvider.notifier).state = [
                  newIndex + 1,
                  -1
                ];
              });
            } else {
              ref.read(chartIndexProvider.notifier).state = [
                ref.watch(chartIndexProvider)[0],
                newIndex
              ];
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
  final String x;
  final double y;
  late final String text;

  ChartData({required this.x, required this.y}) {
    text = '$x $y%';
  }
}
