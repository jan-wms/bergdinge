import 'package:equipment_app/data/design.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatefulWidget {
  final List<ChartData> chartData;
  final ValueSetter<int> onTouchedIndexChanged;

  const CustomPieChart(
      {super.key,
      required this.chartData,
      required this.onTouchedIndexChanged});

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int touchedPieChartIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sectionData =
        widget.chartData.asMap().entries.map((e) {
      final isTouched = e.key == touchedPieChartIndex;
      return PieChartSectionData(
        color: isTouched || touchedPieChartIndex == -1 ? Design.getSectionColor(e.key) : Design.getDisabledSectionColor(e.key),
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
            final newIndex =
                pieTouchResponse.touchedSection!.touchedSectionIndex;
            if (newIndex == -1 && touchedPieChartIndex == -1) return;
            setState(() {
              touchedPieChartIndex =
                  (touchedPieChartIndex == newIndex) ? -1 : newIndex;
            });
            widget.onTouchedIndexChanged(touchedPieChartIndex);
          },
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 150),
      swapAnimationCurve: Curves.linear,
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
