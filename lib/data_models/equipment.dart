import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/data.dart';

class Equipment {
  String name;
  double weight;
  EquipmentStatus status;
  String? size;
  String? brand;
  double? uvp;
  double? price;
  DateTime? purchaseDate;
  int category;
  int count;
  List<String>? sports;
  String id;
  final Map<double, String>? runningCosts;
  final Map<int, String>? daysInUse;

  Equipment({
    required this.name,
    required this.weight,
    required this.status,
    required this.id,
    this.size,
    this.sports,
    this.brand,
    this.uvp,
    this.price,
    this.daysInUse,
    this.purchaseDate,
    required this.category,
    required this.count,
    this.runningCosts,
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
      /*
      daysInUse:
          data?['daysInUse'] is Iterable ? Map.from(data?['daysInUse']) : null,
      runningCosts: data?['runningCosts'] is Iterable
          ? Map.from(data?['runningCosts'])
          : null,*/
      name: data?['name'],
      id: data?['id'],
      weight: (data?['weight'] as num).toDouble(),
      size: data?['size'],
      status: EquipmentStatus.fromString(data?['status']),
      uvp: data?['uvp'] != null ? (data?['uvp'] as num).toDouble() : null,
      price: data?['price'] != null ? (data?['price'] as num).toDouble() : null,
      brand: data?['brand'],
      purchaseDate: DateTime.tryParse(data?['purchaseDate'] ?? ''),
      category: (data?['category'] as num).toInt(),
      count: (data?['count'] as num).toInt(),
      sports: data?['sports'] is Iterable ? List.from(data?['sports']) : null,
      daysInUse: null,
      runningCosts: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "id": id,
      "weight": weight,
      "status": status.toString(),
      if (size != null) "size": size,
      if (uvp != null) "uvp": uvp,
      if (price != null) "price": price,
      if (brand != null) "brand": brand,
      if (daysInUse != null) "daysInUse": daysInUse,
      if (purchaseDate != null) "purchaseDate": purchaseDate.toString(),
      "category": category,
      "count": count,
      if (sports != null) "sports": sports,
      if (runningCosts != null) "runningCosts": runningCosts,
    };
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
