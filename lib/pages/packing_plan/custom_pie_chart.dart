import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatelessWidget {
  final List<ChartData> chartData;
  final ValueGetter<int> onTouchedIndexChanged;
  const CustomPieChart({super.key, required this.chartData, required this.onTouchedIndexChanged});

  final List<Color> sectionColor = [
    Colors.blueAccent,
    Colors.lightBlueAccent,
    Colors.blueGrey,
    Colors.lightBlue,
    Colors.blue,
  ];
  final List<Color> textColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  final List<PieChartSectionData> sectionData =
  chartData.asMap().entries.map((e) {
  final isTouched = e.key == ref.watch(touchedPieChartIndex);
  return PieChartSectionData(
  color: sectionColor[e.key],
  value: e.value.y,
  title: e.value.text,
  radius: isTouched ? 110.0 : 100.0,
  titleStyle: TextStyle(color: textColor[e.key]),
  );
  }).toList();


  @override
  Widget build(BuildContext context) {
    return PieChart(
    PieChartData(
    sections: sectionData,
    centerSpaceRadius: 0,
  sectionsSpace: 0,
  pieTouchData: PieTouchData(
  longPressDuration: const Duration(seconds: 2),
  touchCallback: (FlTouchEvent event, pieTouchResponse) {
  if (!event.isInterestedForInteractions ||
  pieTouchResponse == null ||
  pieTouchResponse.touchedSection == null ||
  event.runtimeType != FlTapDownEvent) {
  return;
  }
  final touchedIndex =
  pieTouchResponse.touchedSection!.touchedSectionIndex;
  ref.read(touchedPieChartIndex.notifier).state =
  (ref.read(touchedPieChartIndex) == touchedIndex)
  ? -1
      : touchedIndex;
  },
  ),
  ),
      swapAnimationDuration: const Duration(milliseconds: 150),
      // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}

class ChartData {
  final String x;
  final double y;
  late final String text;

  ChartData({required this.x, required this.y}) {
    text = '$x\n$y%';
  }
}

