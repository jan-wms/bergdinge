import 'package:equipment_app/data_models/packing_plan.dart';

import '../data/data.dart';

class Tip {
  final String title;
  final String subTitle;
  final List<String> relevantSports;
  final bool conditionIsMet;
  Tip({required this.title, required this.subTitle, required this.relevantSports, required this.conditionIsMet}) : assert(relevantSports.every((element) => Data.sports.contains(element)));

  bool isRelevant (PackingPlan packingPlan) {
    for(var sport in packingPlan.sports) {
      if(relevantSports.contains(sport)) {
        return true;
      }
    }
    return false;
  }
}