import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/pages/equipment/equipment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/data.dart';
import '../../data_models/category.dart';
import '../../data_models/equipment.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  const EquipmentPage({super.key});

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  final controller = TextEditingController();

  Map<String, List<Equipment>> getCategoryStructure(
      {required List<Category> categoryList,
      required List<Equipment> data,
      required int depth}) {
    Map<String, List<Equipment>> categoryStructure = {};
    for (var c in categoryList) {
      categoryStructure[c.name] = [];
    }

    for (var e in data) {
      categoryStructure[Data.getCategoriyListFromID(
                  pList: Data.categories,
                  pResult: [],
                  categoryID: e.category)[depth]
              .name]
          ?.add(e);
    }
    categoryStructure.removeWhere((key, value) => value.isEmpty);
    return categoryStructure;
  }

  List<Widget> getLol(
      {required Map<String, List<Equipment>> currentCategoryStructure,
      required String currentKey,
      required List<Equipment> data}) {
    List<Widget> result = [];

    if (currentKey == 'Bekleidung' || currentKey == 'Ausrüstung') {
      Map<String, List<Equipment>> newCategoryStructure = getCategoryStructure(
          categoryList: Data.categories
              .singleWhere((element) => element.name == currentKey)
              .subCategories!,
          data: data,
          depth: 1);
      newCategoryStructure.forEach((key, value) {
        result.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(key.toString()),
              Wrap(
                children: getLol(
                    currentCategoryStructure: newCategoryStructure,
                    data: data,
                    currentKey: key),
              ),
            ],
          ),
        );
      });
    } else {
      currentCategoryStructure[currentKey]?.forEach((element) {
        result.add(EquipmentCard(equipment: element));
      });
    }

    return result;
  }

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

              Map<String, List<Equipment>> categoryStructure =
                  getCategoryStructure(
                      categoryList: Data.categories, data: data, depth: 0);

              return ListView(
                children: [
                  for (var key in categoryStructure.keys)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(key.toString()),
                        Wrap(
                          children: getLol(
                              currentCategoryStructure: categoryStructure,
                              data: data,
                              currentKey: key),
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
