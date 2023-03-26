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
  late DateTime? purchaseDate;
  late List<String>? categories;
  late List<String>? sport;
  late Map<double, String>? runningCosts;
  late Map<int, String>? daysInUse;
  void add() {}

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
        Wrap(
            spacing: 10,
            children: const [
              Chip(
                label: Text('Working'),
                avatar: Icon(
                  Icons.work,
                  color: Colors.red,
                ),
                backgroundColor: Colors.amberAccent,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
              Chip(
                label: Text('Music'),
                avatar: Icon(Icons.headphones),
                backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
            ]),
        ElevatedButton(
            onPressed: () => add(), child: const Text('Hinzufügen')),
      ],
    );
  }
}