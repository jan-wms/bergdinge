import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String name;
  final double weight;
  final String status;
  final String? size;
  final String? brand;
  final double? uvp;
  final double? price;
  final DateTime? purchaseDate;
  final List<String>? categories;
  final List<String>? sport;
  final Map<double, String>? runningCosts;
  final Map<int, String>? daysInUse;

  Equipment({
    required this.name,
    required this.weight,
    required this.status,
    this.size,
    this.sport,
    this.brand,
    this.uvp,
    this.price,
    this.daysInUse,
    this.purchaseDate,
    this.categories,
    this.runningCosts,
  });

  factory Equipment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Equipment(
      name: data?['name'],
      weight: data?['weight'],
      size: data?['size'],
      status: data?['status'],
      uvp: data?['uvp'],
      price: data?['price'],
      brand: data?['brand'],
      purchaseDate: data?['purchaseDate'],
      categories: data?['categories'] is Iterable
          ? List.from(data?['categories'])
          : null,
      sport: data?['sport'] is Iterable ? List.from(data?['sport']) : null,
      daysInUse:
          data?['daysInUse'] is Iterable ? Map.from(data?['daysInUse']) : null,
      runningCosts: data?['runningCosts'] is Iterable
          ? Map.from(data?['runningCosts'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "weight": weight,
      "status": status,
      if (size != null) "size": size,
      if (uvp != null) "uvp": uvp,
      if (price != null) "price": price,
      if (brand != null) "brand": brand,
      if (daysInUse != null) "daysInUse": daysInUse,
      if (purchaseDate != null) "purchaseDate": purchaseDate,
      if (categories != null) "categories": categories,
      if (sport != null) "sport": sport,
      if (runningCosts != null) "runningCosts": runningCosts,
    };
  }
}
