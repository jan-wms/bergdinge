import 'package:bergdinge/data/data.dart';

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

  static String? category(String? value) {
    if (value == null || value == '-1') {
      return "Ungültiger Wert.";
    }
    return null;
  }

  static String? count(int? value) {
    if (value == null || value < 1) {
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

  static String? sports(List<String>? value) {
    if (value == null) {
      return null;
    }
    for (var item in value) {
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
