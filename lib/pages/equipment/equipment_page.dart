import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/pages/equipment/equipment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/data.dart';
import '../../data_models/equipment.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  const EquipmentPage({super.key});

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final equipmentList = ref.watch(equipmentStreamProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              const Text(
                'Meine Ausrüstung',
              ),
              ElevatedButton(
                  onPressed: () => context.push('/equipment/edit'),
                  child: const Text('Gegenstand hinzufügen')),
            ],
          ),
          TextField(
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
          Expanded(
              child: equipmentList.when(
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator.adaptive(),
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
                  return const Text('Leider konnte nichts gefunden werden.');
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return EquipmentCard(equipment: items[index]);
                  },
                );
              }

              return ListView(
                children: [
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
                                        EquipmentCard(equipment: element)
                                    ]
                                  ),
                                ],
                              ),
                            if (category.name == 'Schuhe' || category.name == 'Verpflegung')
                            for(var element in data.where((element) => element.category.startsWith('${category.id}.')))
                            EquipmentCard(equipment: element)
                          ]
                        ),
                      ],
                    ),
                ],
              );
            },
          ))
        ],
      ),
    );
  }
}
