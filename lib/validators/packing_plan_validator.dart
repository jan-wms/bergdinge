import 'package:equipment_app/data_models/packing_plan_item.dart';

import '../data/data.dart';

class PackingPlanValidator {
  static String? name(value) {
    if (value?.isEmpty ?? true) {
      return 'Bitte einen Namen eingeben';
    }
    return null;
  }

  static String? sports(List<String>? value) {
    if (value == null || value.isEmpty) {
      return "Bitte wähle mindestens eine Sportart.";
    }
    for (var item in value) {
      if (!Data.sports.contains(item)) {
        return "Unbekannter Sport.";
      }
    }
    return null;
  }

  static String? items(List<PackingPlanItem>? value) {
    if(value == null || value.isEmpty) {
      return "Bitte füge Ausrüstung zu deiner Packliste hinzu.";
    }
    return null;
  }
}