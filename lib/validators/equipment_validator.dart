import 'package:equipment_app/data/data.dart';

class EquipmentValidator {
  static String? priceOrUvp(value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    if (double.tryParse(value) == null) {
      return "Bitte eine gültige Zahl eingeben.";
    }
    if (double.parse(value) < 0) {
      return "Der Wert darf nicht kleiner als 0 sein.";
    }
    return null;
  }

  static String? name(value) {
    if (value?.isEmpty ?? true) {
      return 'Bitte einen Namen eingeben';
    }
    return null;
  }

  static String? brand(value) {
    return null;
  }

  static String? categoryOrCount(int? value) {
    if (value == null || value < 0) {
      return "Ungültiger Wert.";
    }
    return null;
  }

  static String? weight(value) {
    if (value?.isEmpty ?? true) {
      return "Bitte gib das Gewicht ein.";
    }
    if (int.tryParse(value) == null || int.parse(value) < 0) {
      return "Ungültiger Wert.";
    }
    return null;
  }

  static String? size(value) {
    return null;
  }

  static String? purchaseDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    if (value.isAfter(DateTime.now())) {
      return "Das Kaufdatum darf nicht in der Zukunft liegen.";
    }
    return null;
  }

  static String? sports(value) {
    if (value == null) {
      return null;
    }
    if (value.runtimeType != List<String>) {
      return "Falscher Datentyp: ${value.runtimeType.toString()} ist nicht vom Typ List<String>.";
    }
    for (var item in value as List<String>) {
      if (!Data.sports.contains(item)) {
        return "Unbekannter Sport.";
      }
    }
    return null;
  }

  static String? runningCosts(value) {
    return null;
  }

  static String? daysInUse(value) {
    return null;
  }
}
