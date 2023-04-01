import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';

import '../../firebase/firebase_auth.dart';

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

  void add() async {
    Equipment e = Equipment(
      name: _controllerName.text,
      weight: double.parse(_controllerWeight.text),
      status: _controllerStatus.text,
      brand: _controllerBrand.text,
      price: double.parse(_controllerPrice.text),
      size: _controllerSize.text,
      uvp: double.parse(_controllerUvp.text),
      categories: categories,
      sports: sports,
      daysInUse: null,
      purchaseDate: null,
      runningCosts: null,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('equipment')
        .add(e.toFirestore());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(''),
            const Text('Gegenstand hinzufügen'),
            ElevatedButton(
                onPressed: () => add(), child: const Text('Hinzufügen')),
          ],
        ),
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
        Text(purchaseDate?.toString() ?? 'not definded'),
      ],
    );
  }
}
