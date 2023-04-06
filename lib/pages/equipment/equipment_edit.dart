import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/show_custom_modal.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/category.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import '../../custom_widgets/select_sports.dart';
import '../../firebase/firebase_auth.dart';

class EquipmentEdit extends StatefulWidget {
  final Equipment? equipment;

  const EquipmentEdit({super.key, this.equipment});

  @override
  State<EquipmentEdit> createState() => _EquipmentEditState();
}

class _EquipmentEditState extends State<EquipmentEdit> {
  late Equipment equipment;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerBrand = TextEditingController();
  final TextEditingController _controllerWeight = TextEditingController();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerSize = TextEditingController();
  final TextEditingController _controllerUvp = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    equipment = widget.equipment ??
        Equipment(
          name: 'Fehler',
          weight: 0.0,
          brand: null,
          size: null,
          price: null,
          purchaseDate: null,
          uvp: null,
          status: EquipmentStatus.active,
          sports: <String>[],
          category: -1,
          count: 1,
          runningCosts: null,
          daysInUse: null,
        );

    if (widget.equipment != null) {
      _controllerName.text = equipment.name;
      _controllerBrand.text = equipment.brand ?? '';
      _controllerWeight.text = equipment.weight.toString();
      _controllerPrice.text = (equipment.price ?? '').toString();
      _controllerSize.text = equipment.size ?? '';
      _controllerUvp.text = (equipment.uvp ?? '').toString();
    }
  }

  void edit() async {
    equipment.name = _controllerName.text;
    equipment.brand = _controllerBrand.text;
    equipment.weight = double.parse(_controllerWeight.text);
    equipment.price = _controllerPrice.text.isNotEmpty
        ? double.parse(_controllerPrice.text)
        : null;
    equipment.size = _controllerSize.text;
    equipment.uvp = _controllerUvp.text.isNotEmpty
        ? double.parse(_controllerUvp.text)
        : null;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('equipment')
        .add(equipment.toMap());
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
            Text('Gegenstand ${widget.equipment != null ? 'bearbeiten' : 'hinzufügen'}'),
            ElevatedButton(
                onPressed: () => edit(), child: Text(widget.equipment != null ? ''
                'Bearbeiten' : 'Hinzufügen')),
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
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (equipment.count > 1) equipment.count--;
                  });
                },
                child: const Text('-')),
            Text(equipment.count.toString()),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    equipment.count++;
                  });
                },
                child: const Text('+')),
          ],
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
              equipment.purchaseDate = d;
            });
          },
          child:
              Text(equipment.purchaseDate?.toString() ?? 'date not definded'),
        ),
        ListTile(
          title: Text(equipment.sports!.isNotEmpty
              ? equipment.sports.toString()
              : 'Sportart'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            final List<String> s =
                await selectSports(context, equipment.sports!);
            setState(() {
              equipment.sports = s;
            });
          },
        ),
        ListTile(
          title: Text('Kategorie: ${equipment.category}'),
          trailing: const Icon(Icons.chevron_right_outlined),
          onTap: () async {
            final int i = await selectCategory(context, equipment.category);
            setState(() {
              equipment.category = i;
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
  final List<Category> data = Data.categories;
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
