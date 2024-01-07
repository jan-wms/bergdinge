import 'package:equipment_app/data/design.dart';
import 'package:flutter/material.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';


import '../../data/data.dart';
import '../../data_models/equipment.dart';
import 'equipment_card.dart';

class EquipmentList extends ConsumerStatefulWidget {
  const EquipmentList({required this.onItemClick, this.packingPlanId, super.key});
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

    return MultiSliver(
      children: [
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          title: SizedBox(
            width: double.infinity,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Suchen',
                  suffix: (controller.text.isNotEmpty)
                      ? IconButton(
                      onPressed: () => setState(() {
                        controller.text = '';
                      }),
                      icon: const Icon(Icons.clear))
                      : null),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
        SliverPadding(
          padding: Design.pagePadding,
          sliver: equipmentList.when(
            error: (error, stackTrace) => SliverToBoxAdapter(child: Text(error.toString())),
            loading: () => const SliverToBoxAdapter(child: CircularProgressIndicator.adaptive()),
            data: (data) {

              String searchPattern = controller.text.toLowerCase();
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
                    child: Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_emotions_rounded),
                        Text('Leider konnte nichts gefunden werden.'),
                      ],
                    )),
                  );
                  return const SliverToBoxAdapter(child: Text('Leider konnte nichts gefunden werden.'));
                }
                return SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return EquipmentCard(equipment: items[index], onClick: (equipmentId) => widget.onItemClick(equipmentId), packingPlanId: widget.packingPlanId,);
                  },
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate(
                  [
                  for (var category in Data.categories)
                    if(data.where((element) => element.category.startsWith('${category.id}.')).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.name),
                          Wrap(
                              children: [
                                if (category.name == 'Ausrüstung' || category.name == 'Bekleidung')
                                  for(var subCategory in category.subCategories!)
                                    if(data.where((element) => element.category.startsWith('${subCategory.id}.')).isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(subCategory.name.toString()),
                                          Wrap(
                                              children: [
                                                for(var element in data.where((element) => element.category.startsWith('${subCategory.id}.')))
                                                EquipmentCard(equipment: element, onClick: (equipmentId) => widget.onItemClick(equipmentId), packingPlanId: widget.packingPlanId)
                                              ]
                                          ),
                                        ],
                                      ),
                                if (category.name == 'Schuhe' || category.name == 'Verpflegung')
                                  for(var element in data.where((element) => element.category.startsWith('${category.id}.')))
                                    EquipmentCard(equipment: element, onClick: (equipmentId) => widget.onItemClick(equipmentId), packingPlanId: widget.packingPlanId)
                              ]
                          ),
                        ],
                      ),
                ],),
              );
            },
          ),
        ),],
    );
  }
}
