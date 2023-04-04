import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/show_custom_modal.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/category.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/select_sports.dart';
import '../../firebase/firebase_auth.dart';

class EquipmentEdit extends StatefulWidget {
  const EquipmentEdit({super.key});

  @override
  State<EquipmentEdit> createState() => _EquipmentEditState();
}

class _EquipmentEditState extends State<EquipmentEdit> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerBrand = TextEditingController();
  final TextEditingController _controllerWeight = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerSize = TextEditingController();
  final TextEditingController _controllerStatus = TextEditingController();
  final TextEditingController _controllerUvp = TextEditingController();
  int category = -1;
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
      price: _controllerPrice.text.isNotEmpty ? double.parse(_controllerPrice.text) : null,
      size: _controllerSize.text,
      uvp: _controllerUvp.text.isNotEmpty ? double.parse(_controllerUvp.text) : null,
      category: category,
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
          controller: _controllerBrand,
          decoration: const InputDecoration(hintText: 'Hersteller'),
        ),
        TextField(
          controller: _controllerName,
          decoration: const InputDecoration(hintText: 'Name'),
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
          title: Text('Kategorie: $category'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            final int i = await selectCategory(context, category);
            setState(() {
              category = i;
            });
          },
        ),
      ],
    );
  }
}

Future<int> selectCategory(BuildContext context, int selected) async {
  final GlobalKey<_SelectCategoryState> k = GlobalKey();
  final SelectCategory selectCategory = SelectCategory(
    key: k,
    selected: selected,
  );
  await showCustomModal(
    context,
    selectCategory,
    null,
    TextButton(
      child: const Text('Close'),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
  return k.currentState!.selected;
}

class SelectCategory extends StatefulWidget {
  final int selected;

  const SelectCategory({Key? key, required this.selected}) : super(key: key);

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final List<Category> data = Data().categories;
  late int selected = widget.selected;

  List<Widget> createCategories(List<Category> categories) {
    List<Widget> widgets = <Widget>[];
    for (var element in categories) {
      if (element.subCategories == null) {
        widgets.add(ListTile(
          title: Text(element.name),
          onTap: () {
            setState(() {
              selected = element.id;
            });
          },
          trailing: element.id == selected ? const Icon(Icons.check) : null,
        ));
      } else {
        widgets.add(ExpansionTile(
          title: Text(element.name),
          children: createCategories(element.subCategories!),
        ));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Kategorie'),
        const TextField(),
        Expanded(
          child: ListView(
            children: createCategories(data),
          ),
        )
      ],
    );
  }
}
