import 'package:bergdinge/firebase/firebase_data_providers.dart';
import 'package:bergdinge/screens/packing_plan/details/app_bar_actions.dart';
import 'package:bergdinge/screens/packing_plan/details/analysis.dart';
import 'package:bergdinge/screens/packing_plan/details/tools_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/design.dart';
import '../../../widgets/small_app_bar.dart';

class Details extends ConsumerWidget {
  final String packingPlanId;

  const Details({super.key, required this.packingPlanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(packingPlanDetailsProvider(packingPlanId));
    final isWide =
        MediaQuery.of(context).size.width > Design.wideScreenBreakpoint;
    return Scaffold(
      backgroundColor: Colors.white,
      body: details.when(
          error: (e, _) => Center(
                child: Text(e.toString()),
              ),
          loading: () => _Loading(),
          data: (data) {
            return Column(
              children: [
                SmallAppBar(
                  title: data.packingPlan.name,
                  actions: [
                    AppBarActions(
                      packingPlan: data.packingPlan,
                    )
                  ],
                ),
                Expanded(
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: data.items.isEmpty
                                      ? _NoItems()
                                      : ListView(
                                          padding: EdgeInsets.zero,
                                          children: [
                                            Analysis(data: data),
                                          ],
                                        )),
                              Expanded(
                                  child: ToolsSection(data: data)),
                            ],
                          )
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              ToolsSection(data: data),
                              if (data.items.isNotEmpty) Analysis(data: data),
                              if (data.items.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 35.0),
                                  child: _NoItems(),
                                )
                            ],
                          )),
              ],
            );
          }),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SmallAppBar(title: ''),
        Expanded(
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        )
      ],
    );
  }
}

class _NoItems extends StatelessWidget {
  const _NoItems();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Füge Ausrüstung hinzu.',
          style: TextStyle(color: Colors.black54)),
    );
  }
}
