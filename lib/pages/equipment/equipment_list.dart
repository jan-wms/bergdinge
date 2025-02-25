import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/pages/equipment/equipment_page.dart';
import 'package:flutter/material.dart';
import 'package:bergdinge/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../data_models/equipment.dart';
import 'equipment_card.dart';

class EquipmentList extends ConsumerStatefulWidget {
  const EquipmentList(
      {required this.onItemClick, this.packingPlanId, super.key});

  final ValueSetter<String> onItemClick;
  final String? packingPlanId;

  @override
  ConsumerState<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends ConsumerState<EquipmentList> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final equipmentList = ref.watch(equipmentStreamProvider);

    return SliverPadding(
      padding: Design.pagePadding.copyWith(top: 20.0),
      sliver: equipmentList.when(
        error: (error, stackTrace) =>
            SliverToBoxAdapter(child: Text(error.toString())),
        loading: () => const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        data: (data) {
          if (data.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(widget.packingPlanId != null
                    ? 'Es ist noch keine Ausrüstung vorhanden.'
                    : 'Füge Ausrüstung hinzu.'),
              ),
            );
          }

          String searchPattern =
              ref.watch(equipmentSearchProvider).toLowerCase();
          if (searchPattern.isNotEmpty) {
            List<Equipment> items = data
                .where((element) =>
                    element.brand?.toLowerCase().contains(searchPattern) ??
                    false)
                .toList();
            items.addAll(data.where((element) =>
                !items.contains(element) &&
                (element.name.toLowerCase().contains(searchPattern))));
            if (items.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('Leider konnte nichts gefunden werden.'),
                ),
              );
            }
            return SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: Design.pagePadding.left,
                  runSpacing: Design.pagePadding.left,
                  children: [
                    for (var item in items)
                      EquipmentCard(
                        equipment: item,
                        onClick: (equipmentId) => widget.onItemClick(equipmentId),
                        packingPlanId: widget.packingPlanId,
                      ),
                  ],
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildListDelegate(
              [
                for (var category in Data.categories)
                  if (data
                      .where((element) =>
                          element.category.startsWith('${category.id}.'))
                      .isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 27),
                          ),
                          Padding(
                            padding: (category.name == 'Ausrüstung' ||
                                    category.name == 'Bekleidung')
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(
                                    top: 15.0, bottom: 20.0),
                            child: Wrap(
                                spacing: Design.pagePadding.left,
                                runSpacing: Design.pagePadding.left,
                                children: [
                                  if (category.name == 'Ausrüstung' ||
                                      category.name == 'Bekleidung')
                                    for (var subCategory
                                        in category.subCategories!)
                                      if (data
                                          .where((element) => element.category
                                              .startsWith('${subCategory.id}.'))
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15.0),
                                                child: Text(
                                                  subCategory.name.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 20),
                                                ),
                                              ),
                                              Wrap(
                                                  spacing:
                                                      Design.pagePadding.left,
                                                  runSpacing:
                                                      Design.pagePadding.left,
                                                  children: [
                                                    for (var element in data.where(
                                                        (element) => element
                                                            .category
                                                            .startsWith(
                                                                '${subCategory.id}.')))
                                                      EquipmentCard(
                                                          equipment: element,
                                                          onClick: (equipmentId) =>
                                                              widget.onItemClick(
                                                                  equipmentId),
                                                          packingPlanId: widget
                                                              .packingPlanId)
                                                  ]),
                                            ],
                                          ),
                                        ),
                                  if (category.name == 'Schuhe' ||
                                      category.name == 'Verpflegung')
                                    for (var element in data.where((element) =>
                                        element.category
                                            .startsWith('${category.id}.')))
                                      EquipmentCard(
                                          equipment: element,
                                          onClick: (equipmentId) =>
                                              widget.onItemClick(equipmentId),
                                          packingPlanId: widget.packingPlanId)
                                ]),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
