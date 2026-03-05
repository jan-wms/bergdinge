import 'package:bergdinge/widgets/custom_sliver_app_bar.dart';
import 'package:bergdinge/widgets/custom_dialog.dart';
import 'package:bergdinge/screens/packing_plan/packing_plan_card.dart';
import 'package:bergdinge/screens/packing_plan/packing_plan_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/design.dart';
import '../../firebase/firebase_data_providers.dart';
import '../../models/packing_plan.dart';

class PackingPlanPage extends ConsumerStatefulWidget {
  const PackingPlanPage({super.key});

  @override
  ConsumerState<PackingPlanPage> createState() => _PackingPlanPageState();
}

class _PackingPlanPageState extends ConsumerState<PackingPlanPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);

    return CustomScrollView(slivers: <Widget>[
      CustomSliverAppBar(
          searchInitialValue: _search,
          title: 'Packlisten',
          icon: Icons.terrain,

          onButtonPressed: () => CustomDialog.showCustomModal(
              context: context, child: const PackingPlanEdit()),
          onSearchChanged: (value) => setState(() {
            _search = value;
          }),
        ),
        packingPlanList.when(
          error: (error, stackTrace) =>
              SliverToBoxAdapter(child: Text(error.toString())),
          loading: () => _ShimmerLoading(),
          data: (data) {
            if (data.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Erstelle deine erste Packliste.')),
              );
            }

            List<PackingPlan> dataToDisplay = data;

            String searchPattern =
                _search.toLowerCase();
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

class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
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
    );
  }
}

