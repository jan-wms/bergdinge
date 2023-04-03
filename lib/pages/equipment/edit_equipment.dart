import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/show_custom_modal.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';

import '../../firebase/firebase_auth.dart';

class EditEquipment extends StatefulWidget {
  const EditEquipment({super.key});

  @override
  State<EditEquipment> createState() => _EditEquipmentState();
}

class _EditEquipmentState extends State<EditEquipment> {
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
      purchaseDate: purchaseDate,
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
        ElevatedButton(
          onPressed: () async {
            final DateTime? d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            setState(() {
              purchaseDate = d;
            });
          },
          child: Text(purchaseDate?.toString() ?? 'date not definded'),
        ),
        ListTile(
          title: Text(sports.isNotEmpty ? sports.toString() : 'Sportart'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            final List<String> s = await selectSports(context, sports);
            setState(() {
              sports = s;
            });
          },
        ),
        ListTile(
          title: Text(categories.isNotEmpty ? sports.toString() : 'Kategorie'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () => selectCategory(context),
        ),
      ],
    );
  }
}

Future<List<String>> selectSports(BuildContext context, List<String> selected) async {
  final GlobalKey<_SelectSportsState> k = GlobalKey();
  final SelectSports selectSports = SelectSports(key: k, selected: selected,);
  await showCustomModal(
    context,
    selectSports,
    null,
    IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close),
    ),
  );
  return k.currentState!.selected;
}

class SelectSports extends StatefulWidget {
  final List<String> selected;
  const SelectSports({Key? key, required this.selected}) : super(key: key);

  @override
  State<SelectSports> createState() => _SelectSportsState();
}

class _SelectSportsState extends State<SelectSports> {
  late List<String> selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Sportarten'),
        Wrap(spacing: 5.0, children: [
          for (var sport in Data().sports)
            FilterChip(
              label: Text(sport),
              selected: selected.contains(sport),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    if (!selected.contains(sport)) {
                      selected.add(sport);
                    }
                  } else {
                    selected.removeWhere((String s) {
                      return s == sport;
                    });
                  }
                });
              },
            )
        ]),
      ],
    );
  }
}

void selectCategory(BuildContext context) {
  showCustomModal(
    context,
    const SelectCategory(),
    null,
    TextButton(
      child: const Text('Close'),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
}

class SelectCategory extends StatefulWidget {
  const SelectCategory({Key? key}) : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('Kategorie'),
        TextField(),
      ],
    );
  }
}
