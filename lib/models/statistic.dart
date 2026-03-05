import 'dart:collection';
import 'dart:math';

import 'package:bergdinge/models/equipment.dart';
import 'package:bergdinge/models/packing_plan_location.dart';
import 'package:bergdinge/utilities/parser.dart';
import 'package:collection/collection.dart';

import '../data/category_data.dart';
import 'packing_plan_item.dart';
import '../screens/packing_plan/details/custom_pie_chart.dart';

class Statistic {
  String parentCategory;
  late final SplayTreeMap<String, List<PackingPlanItem>> categoryItemsMap;

  Statistic(
      {required List<PackingPlanItem> items,
      this.parentCategory = '',
      required List<Equipment> equipmentList}) {
    categoryItemsMap = SplayTreeMap();

    setMap(items: items, equipmentList: equipmentList);

    if (categoryItemsMap.length == 1 &&
        parentCategory.split('.').length == 1 &&
        (parentCategory.startsWith('0') || parentCategory.startsWith('1'))) {
      parentCategory = categoryItemsMap.keys.single;
      setMap(
          equipmentList: equipmentList, items: categoryItemsMap.values.single);
    }
  }

  void setMap(
      {required List<PackingPlanItem> items,
      required List<Equipment> equipmentList}) {
    categoryItemsMap.clear();
    for (PackingPlanItem i in items) {
      Equipment e =
          equipmentList.singleWhere((element) => element.id == i.equipmentId);

      String category = resolveCategory(e.category);

      categoryItemsMap.containsKey(category)
          ? categoryItemsMap[category]!.add(i)
          : categoryItemsMap[category] = [i];
    }
  }

  bool update(
      {required List<PackingPlanItem> items,
      required List<Equipment> equipment,
      required int locationIndex}) {
    final newItems = List<PackingPlanItem>.from(items);

    for (final entry in categoryItemsMap.entries) {
      final toRemove = <PackingPlanItem>[];
      for (final item in entry.value) {
        final updatedItem = items.singleWhereOrNull((e) =>
            e.equipmentId == item.equipmentId && e.location == item.location);
        if (updatedItem != null) {
          newItems.remove(updatedItem);
          item.equipmentCount = updatedItem.equipmentCount;
          item.isChecked = updatedItem.isChecked;
        } else {
          toRemove.add(item);
        }
      }
      entry.value.removeWhere((i) => toRemove.contains(i));
    }

    for (final item in newItems) {
      Equipment e =
          equipment.singleWhere((element) => element.id == item.equipmentId);
      if (!e.category.startsWith(parentCategory) ||
          (locationIndex > 0 &&
              item.location != PackingPlanLocation.values[locationIndex - 1])) {
        continue;
      }

      String category = resolveCategory(e.category);

      categoryItemsMap.containsKey(category)
          ? categoryItemsMap[category]!.add(item)
          : categoryItemsMap[category] = [item];
    }

    categoryItemsMap.removeWhere((_, v) => v.isEmpty);

    return categoryItemsMap.isNotEmpty;
  }

  String resolveCategory(String fullCategory) {
    if (fullCategory == parentCategory) return fullCategory;

    final sub = fullCategory.substring(parentCategory.length);
    final nextDot = sub.indexOf('.', 1);
    final trimmed = nextDot != -1 ? sub.substring(0, nextDot) : sub;

    return parentCategory + trimmed;
  }

  String get title => parentCategory.isEmpty
      ? ''
      : CategoryData.flatMapCategories(parentCategory).last.name;

  double getWeightFromItems(
      List<PackingPlanItem>? items, List<Equipment> equipmentList) {
    var result = 0.0;
    if (items != null) {
      for (PackingPlanItem item in items) {
        result = result +
            (item.equipmentCount *
                equipmentList
                    .singleWhere((element) => element.id == item.equipmentId)
                    .weight);
      }
    }
    return result;
  }

  String absoluteRelativeFromGroup(String key, List<Equipment> equipmentList) {
    final items = categoryItemsMap[key];
    final percentage = max(
        ((getWeightFromItems(items, equipmentList) / weight(equipmentList)) *
                100)
            .roundToDouble(),
        0.1);

    if (percentage == 100.0) {
      return '${Parser.thousandDot(getWeightFromItems(items, equipmentList))}g';
    } else {
      return '${Parser.thousandDot(getWeightFromItems(items, equipmentList))}g ($percentage%)';
    }
  }

  MapEntry<String, List<PackingPlanItem>> entryFromIndex(int index) {
    return categoryItemsMap.entries.elementAt(index);
  }

  double weight(List<Equipment> equipmentList) {
    List<PackingPlanItem> allItemsList = [];
    categoryItemsMap.forEach((key, value) {
      allItemsList.addAll(value);
    });

    return getWeightFromItems(allItemsList, equipmentList);
  }

  bool get canBuildChildStatistic {
    if (parentCategory.startsWith('2') || parentCategory.startsWith('3')) {
      return false;
    }
    if (parentCategory.split('.').length > 1) {
      return false;
    }
    return categoryItemsMap.length > 1;
  }

  List<ChartData> chartData(List<Equipment> equipmentList) {
    return categoryItemsMap.entries
        .map((entry) => ChartData(
            rootCategory: int.parse(entry.key.split('.').first),
            category: entry.key,
            value: max(
                ((getWeightFromItems(entry.value, equipmentList) /
                            weight(equipmentList)) *
                        100)
                    .roundToDouble(),
                0.1)))
        .toList();
  }

  static List<PackingPlanItem> sumUpAllLocations(List<PackingPlanItem> items) {
    final result = <PackingPlanItem>[];

    for (final i in items) {
      PackingPlanItem? inList = result
          .firstWhereOrNull((element) => element.equipmentId == i.equipmentId);
      if (inList == null) {
        result.add(PackingPlanItem(
            equipmentCount: i.equipmentCount,
            equipmentId: i.equipmentId,
            isChecked: false,
            location: PackingPlanLocation.backpack));
      } else {
        inList.equipmentCount += i.equipmentCount;
      }
    }

    return result;
  }
}
