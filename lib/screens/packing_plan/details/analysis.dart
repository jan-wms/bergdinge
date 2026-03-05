import 'package:bergdinge/models/packing_plan_details_data.dart';
import 'package:bergdinge/models/packing_plan_location.dart';
import 'package:bergdinge/screens/packing_plan/details/chart_section.dart';
import 'package:bergdinge/screens/packing_plan/details/list_section.dart';
import 'package:bergdinge/models/statistic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/design.dart';

class Analysis extends ConsumerStatefulWidget {
  final PackingPlanDetailsData data;

  const Analysis({super.key, required this.data});

  @override
  ConsumerState<Analysis> createState() => _PackingPlanAnalysisState();
}

class _PackingPlanAnalysisState extends ConsumerState<Analysis>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;

  void _initStatisticStack() {
    final items = _currentIndex == 0
        ? widget.data.items
        : widget.data.items
            .where((i) =>
                i.location == PackingPlanLocation.values[_currentIndex - 1])
            .toList();

    ref.read(statisticProvider.notifier).setList(
        [Statistic(items: items, equipmentList: widget.data.equipment)]);
  }

  void _updateStatisticStack() {
    final notifier = ref.read(statisticProvider.notifier);
    final statistics = ref.read(statisticProvider);

    for (final statistic in statistics.reversed) {
      if (!statistic.update(items: widget.data.items, equipment: widget.data.equipment, locationIndex: _currentIndex)) {
        notifier.pop();
      }
    }

    notifier.update();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 1 + PackingPlanLocation.values.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
        _initStatisticStack();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initStatisticStack();
    });
  }

  @override
  void didUpdateWidget(covariant Analysis oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.items != widget.data.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateStatisticStack();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: DefaultTabController(
        length: 1 + PackingPlanLocation.values.length,
        child: Column(
          children: [
            Container(
              margin: Design.pagePadding.copyWith(bottom: 30.0, top: 70),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxWidth: 400,
              ),
              child: TabBar(
                  controller: _tabController,
                  splashBorderRadius: BorderRadius.circular(30.0),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: Colors.white,
                  unselectedLabelColor: Design.darkGreen,
                  indicator: BoxDecoration(
                    color: Design.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  tabs: [
                    Tab(text: 'Gesamt'),
                    for (PackingPlanLocation location
                        in PackingPlanLocation.values)
                      Tab(text: location.label),
                  ]),
            ),
            ChartSection(
              data: widget.data,
              locationSource: _currentIndex == 0
                  ? null
                  : PackingPlanLocation.values[_currentIndex - 1],
            ),
            ListSection(
              data: widget.data,
              locationSource: _currentIndex == 0
                  ? null
                  : PackingPlanLocation.values[_currentIndex - 1],
            ),
          ],
        ),
      ),
    );
  }
}

final statisticProvider =
    NotifierProvider.autoDispose<StatisticNotifier, List<Statistic>>(
        StatisticNotifier.new);

class StatisticNotifier extends Notifier<List<Statistic>> {
  @override
  List<Statistic> build() {
    return [];
  }

  void setList(List<Statistic> list) {
    state = list;
  }

  void push(Statistic s) {
    state = [...state, s];
  }

  void update() {
    state = [...state];
  }

  void pop() {
    if (state.isEmpty) return;
    state = state.sublist(0, state.length - 1);
    if (state.isEmpty) {
      state = [Statistic(items: [], equipmentList: [])];
    }
  }
}
