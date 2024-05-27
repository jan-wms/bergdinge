import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/data_models/packing_plan_item.dart';

import '../data/data.dart';

class Tip {
  final bool Function(List<PackingPlanItem>? items, List<Equipment> equipmentList) condition;
  final String title;
  final String subTitle;
  final List<String> relevantSports;
  final String imagePath;
  Tip({required this.title, required this.imagePath, required this.subTitle, required this.relevantSports, required this.condition, }) : assert(relevantSports.every((element) => Data.sports.contains(element)));

  bool isRelevant (PackingPlan packingPlan) {
    for(var sport in packingPlan.sports) {
      if(relevantSports.contains(sport)) {
        return true;
      }
    }
    return false;
  }

  bool isConditionMet (List<PackingPlanItem>? items, List<Equipment> equipmentList) {
    return condition(items, equipmentList);
  }
}