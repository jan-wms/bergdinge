import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_card.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/design.dart';
import '../../data/providers.dart';
import '../../data_models/packing_plan.dart';

final packingPlanSearchProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

class PackingPlanPage extends ConsumerWidget {
  const PackingPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);

    return CustomScrollView(slivers: <Widget>[
        CustomAppBar(
          searchInitialValue: ref.watch(packingPlanSearchProvider),
          title: 'Packlisten',
          icon: Icons.terrain,

          onButtonPressed: () => CustomDialog.showCustomModal(
              context: context, child: const PackingPlanEdit()),
          onSearchChanged: (value) => ref
              .read(packingPlanSearchProvider.notifier)
              .update((state) => value),
        ),
        packingPlanList.when(
          error: (error, stackTrace) =>
              SliverToBoxAdapter(child: Text(error.toString())),
          loading: () => SliverList.separated(
            itemCount: 4,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ListTile(
                  enabled: false,
                  onTap: () {},
                  title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 17.0,
                        width: 250.0,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0))),
                      )),
                  subtitle: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 10.0,
                        width: 150.0,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(1.0))),
                      )),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Padding(
                padding: Design.pagePadding,
                child: Divider(
                  height: 0.0,
                ),
              );
            },
          ),
          data: (data) {
            if (data.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Erstelle deine erste Packliste.')),
              );
            }

            List<PackingPlan> dataToDisplay = data;

            String searchPattern =
                ref.watch(packingPlanSearchProvider).toLowerCase();
            if (searchPattern.isNotEmpty) {
              List<PackingPlan> result = data
                  .where((element) =>
                      element.name.toLowerCase().contains(searchPattern))
                  .toList();

              result.addAll(data.where((element) =>
                  !result.contains(element) &&
                  (element.sports
                      .join(',')
                      .toLowerCase()
                      .contains(searchPattern))));

              if (result.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Leider konnte nichts gefunden werden.'),
                  ),
                );
              }
              dataToDisplay = result;
            }

            return SliverList.separated(
              itemCount: dataToDisplay.length,
              itemBuilder: (context, index) {
                final packingPlan = dataToDisplay[index];
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
      ]
    );
  }
}
