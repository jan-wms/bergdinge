import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/design.dart';
import '../../data/providers.dart';

class PackingPlanPage extends ConsumerWidget {
  const PackingPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);

    return SafeArea(
      top: false,
      child: CustomScrollView(slivers: <Widget>[
        CustomAppBar(
          title: 'Packlisten',
          onAddButtonPressed: () => context.push('/packing_plan/edit'),
          onChanged: (_) {},
        ),
        packingPlanList.when(
          error: (error, stackTrace) =>
              SliverToBoxAdapter(child: Text(error.toString())),
          loading: () => const SliverToBoxAdapter(
              child: CircularProgressIndicator.adaptive()),
          data: (data) {
            if(data.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Erstelle deine erste Packliste.')),
              );
            }

            return SliverList.separated(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final packingPlan = data[index];
                return PackingPlanCard(packingPlan: packingPlan);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Padding(
                  padding: Design.pagePadding,
                  child: Divider(
                    height: 0.0,
                  ),
                );
              },
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 20.0)),
      ]),
    );
  }
}
