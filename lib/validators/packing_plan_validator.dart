import '../data/data.dart';
import '../data_models/packing_plan.dart';

class PackingPlanValidator {
  static String? name(value) {
    if (value?.isEmpty ?? true) {
      return 'Erforderlich';
    }
    return null;
  }

  static String? notes(value) {
    return null;
  }

  static String? sports(List<String>? value) {
    if (value == null || value.isEmpty) {
      return "Wähle mindestens eine Kategorie.";
    }
    for (var item in value) {
      if (!Data.sports.contains(item)) {
        return "Fehler: Unbekannter Sport.";
      }
    }
    return null;
  }
}