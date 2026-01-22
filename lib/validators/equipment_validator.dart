import 'package:bergdinge/data/data.dart';

class EquipmentValidator {
  static String? priceOrUvp(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    if (double.tryParse(value!) == null) {
      return "Bitte eine gültige Zahl eingeben.";
    }
    if (double.parse(value) < 0) {
      return "Der Wert darf nicht kleiner als 0 sein.";
    }
    return null;
  }

  static String? name(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Bitte einen Namen eingeben';
    }
    return null;
  }

  static String? brand(String? value) {
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

  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return "Bitte gib das Gewicht ein.";
    }
    if (int.tryParse(value) == null || int.parse(value) < 0) {
      return "Ungültiger Wert.";
    }
    return null;
  }

  static String? size(dynamic value) {
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

  static String? runningCosts(dynamic value) {
    return null;
  }

  static String? daysInUse(dynamic value) {
    return null;
  }
}
