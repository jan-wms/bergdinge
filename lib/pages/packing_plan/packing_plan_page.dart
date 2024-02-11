import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_card.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
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
          onAddButtonPressed: () => CustomDialog.showCustomModal(
              context: context, child: const PackingPlanEdit()),
          onChanged: (_) {},
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
