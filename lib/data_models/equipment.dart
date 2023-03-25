import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String name;
  final String? brand;
  final double weight;
  final String size;
  final String status;
  final double? uvp;
  final double? price;
  final int? daysInUse;
  final DateTime? purchaseDate;
  final List<String>? categories;
  final Map<double, String>? runningCosts;

  Equipment({
    required this.name,
    required this.weight,
    required this.size,
    required this.status,
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
      daysInUse: data?['daysInUse'],
      purchaseDate: data?['purchaseDate'],
      categories:
      data?['categories'] is Iterable ? List.from(data?['categories']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (weight != null) "weight": weight,
      if (size != null) "size": size,
      if (status != null) "status": status,
      if (uvp != null) "uvp": uvp,
      if (price != null) "price": price,
      if(brand != null) "brand": brand,
      if (daysInUse != null) "daysInUse": daysInUse,
      if (purchaseDate != null) "purchaseDate": purchaseDate,
      if (categories != null) "categories": categories,
    };
  }
}