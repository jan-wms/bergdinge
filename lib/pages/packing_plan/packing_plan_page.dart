import 'package:equipment_app/pages/packing_plan/packing_plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers.dart';

class PackingPlanPage extends ConsumerWidget {
  const PackingPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);

    return SafeArea(
        child: CustomScrollView(slivers: <Widget>[
           SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                "Packlisten",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
              titlePadding: EdgeInsets.zero,
              centerTitle: false,
            ),
            actions: [
              IconButton(
                  onPressed: () => context.push('/packing_plan/edit'),
                  icon: const Icon(Icons.add_rounded)),
            ],
          ),



          packingPlanList.when(
            error: (error, stackTrace) => SliverToBoxAdapter(child: Text(error.toString())),
            loading: () => const SliverToBoxAdapter(child: CircularProgressIndicator.adaptive()),
            data: (data) {
              return SliverList.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final packingPlan = data[index];
                  return PackingPlanCard(packingPlan: packingPlan);
                },
              );
            },
          ),
          //TODO remove after testing
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 900,
              child: Placeholder(),
            ) ,
          )
    ]));
  }
}
