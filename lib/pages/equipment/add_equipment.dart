import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';

class AddEquipment extends StatefulWidget {
  const AddEquipment({super.key});

  @override
  State<AddEquipment> createState() => _AddEquipmentState();
}

class _AddEquipmentState extends State<AddEquipment> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerBrand = TextEditingController();
  final TextEditingController _controllerWeight = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerSize = TextEditingController();
  final TextEditingController _controllerStatus = TextEditingController();
  final TextEditingController _controllerUvp = TextEditingController();
  List<String> categories = <String>[];
  List<String> sports = <String>[];

  DateTime? purchaseDate;
  late Map<double, String>? runningCosts;
  late Map<int, String>? daysInUse;

  void add() {
    Equipment e = Equipment(
      name: _controllerName.text,
      weight: _controllerWeight.text as double,
      status: _controllerStatus.text,
      brand: _controllerBrand.text,
      price: _controllerPrice.text as double,
      size: _controllerSize.text,
      uvp: _controllerUvp.text as double,
      categories: categories,
      sports: sports,
      daysInUse: null,
      purchaseDate: null,
      runningCosts: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Gegenstand hinzufügen'),
        TextField(
          controller: _controllerName,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        TextField(
          controller: _controllerBrand,
          decoration: const InputDecoration(hintText: 'Hersteller'),
        ),
        TextField(
          controller: _controllerWeight,
          decoration: const InputDecoration(hintText: 'Gewicht'),
        ),
        TextField(
          controller: _controllerSize,
          decoration: const InputDecoration(hintText: 'Größe'),
        ),
        TextField(
          controller: _controllerPrice,
          decoration: const InputDecoration(hintText: 'Preis'),
        ),
        TextField(
          controller: _controllerUvp,
          decoration: const InputDecoration(hintText: 'UVP'),
        ),
        TextField(
          controller: _controllerStatus,
          decoration: const InputDecoration(hintText: 'Status'),
        ),
        Wrap(spacing: 5.0, children: [
          for (var sport in Data().sports)
            FilterChip(
              label: Text(sport),
              selected: sports.contains(sport),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    if (!sports.contains(sport)) {
                      sports.add(sport);
                    }
                  } else {
                    sports.removeWhere((String s) {
                      return s == sport;
                    });
                  }
                });
              },
            )
        ]),
        Wrap(spacing: 5.0, children: [
          for (var category in Data().categories)
            FilterChip(
              label: Text(category),
              selected: categories.contains(category),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    if (!categories.contains(category)) {
                      categories.add(category);
                    }
                  } else {
                    categories.removeWhere((String s) {
                      return s == category;
                    });
                  }
                });
              },
            )
        ]),
        Text(purchaseDate?.toString() ?? 'not definded'),
        ElevatedButton(onPressed: () => add(), child: const Text('Hinzufügen')),
      ],
    );
  }
}