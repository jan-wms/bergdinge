import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  String name;
  int weight;
  String? size;
  String? brand;
  double? uvp;
  double? price;
  DateTime? purchaseDate;
  String category;
  int count;
  final String id;

  Equipment({
    required this.name,
    required this.weight,
    required this.category,
    required this.count,
    required this.id,
    this.size,
    this.brand,
    this.uvp,
    this.price,
    this.purchaseDate,
  });

  factory Equipment.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Equipment.fromMap(data);
  }

  factory Equipment.fromMap(
      Map<String, dynamic>? data,
      ) {
    return Equipment(
      name: data?['name'],
      id: data?['id'],
      weight: (data?['weight'] as num).toInt(),
      size: data?['size'],
      uvp: data?['uvp'] != null ? (data?['uvp'] as num).toDouble() : null,
      price: data?['price'] != null ? (data?['price'] as num).toDouble() : null,
      brand: data?['brand'],
      purchaseDate: DateTime.tryParse(data?['purchaseDate'] ?? ''),
      category: data?['category'],
      count: (data?['count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "weight": weight,
      if (size != null) "size": size,
      if (uvp != null) "uvp": uvp,
      if (price != null) "price": price,
      if (brand != null) "brand": brand,
      if (purchaseDate != null) "purchaseDate": purchaseDate.toString(),
      "category": category,
      "count": count,
    };
  }

  static String? validatePrice(String? value) {
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

  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Bitte einen Namen eingeben';
    }
    return null;
  }

  static String? validateBrand(String? value) {
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value == '-1') {
      return "Wähle eine Kategorie.";
    }
    return null;
  }

  static String? validateCount(int? value) {
    if (value == null || value < 1) {
      return "Ungültiger Wert.";
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return "Bitte gib das Gewicht ein.";
    }
    if (int.tryParse(value) == null || int.parse(value) < 0) {
      return "Ungültiger Wert.";
    }
    return null;
  }

  static String? validateSize(dynamic value) {
    return null;
  }

  static String? validatePurchaseDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    if (value.isAfter(DateTime.now())) {
      return "Das Kaufdatum darf nicht in der Zukunft liegen.";
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return other is Equipment &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(id, id);
}
