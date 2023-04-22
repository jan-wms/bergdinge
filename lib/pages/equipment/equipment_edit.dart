import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data_models/category.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/validators/equipment_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../custom_widgets/select_sports.dart';
import '../../firebase/firebase_auth.dart';

class EquipmentEdit extends StatefulWidget {
  final Equipment? equipment;

  const EquipmentEdit({super.key, this.equipment});

  @override
  State<EquipmentEdit> createState() => _EquipmentEditState();
}

class _EquipmentEditState extends State<EquipmentEdit> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyCount = GlobalKey<FormFieldState>();
  final _formKeyDate = GlobalKey<FormFieldState>();
  final _formKeyCategory = GlobalKey<FormFieldState>();
  final _formKeySports = GlobalKey<FormFieldState>();

  late final TextEditingController _controllerName = TextEditingController(text: widget.equipment?.name ?? '');
  late final TextEditingController _controllerBrand = TextEditingController(text: widget.equipment?.brand ?? '');
  late final TextEditingController _controllerWeight = TextEditingController(text: (widget.equipment?.weight ?? '').toString());
  late final TextEditingController _controllerPrice = TextEditingController(text: (widget.equipment?.price ?? '').toString());
  late final TextEditingController _controllerSize = TextEditingController(text: widget.equipment?.size ?? '');
  late final TextEditingController _controllerUvp = TextEditingController(text: (widget.equipment?.uvp ?? '').toString());



  void edit() async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('equipment')
        .doc(widget.equipment?.id);

    Equipment e = Equipment(
      name: _controllerName.text,
      weight: int.parse(_controllerWeight.text),
      status: EquipmentStatus.active,
      category: _formKeyCategory.currentState!.value,
      count: _formKeyCount.currentState!.value,
      id: ref.id,
      sports: _formKeySports.currentState!.value,
      purchaseDate: _formKeyDate.currentState!.value,
      uvp: _controllerUvp.text.isNotEmpty
          ? double.parse(_controllerUvp.text.toString().replaceAll(',', '.'))
          : null,
      size: _controllerSize.text,
      price: _controllerPrice.text.isNotEmpty
          ? double.parse(_controllerPrice.text.toString().replaceAll(',', '.'))
          : null,
      brand: _controllerBrand.text,

      daysInUse: null,
      runningCosts: null,
    );

    await ref.set(e.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(''),
                  Text(
                      'Gegenstand ${widget.equipment != null ? 'bearbeiten' : 'hinzufügen'}'),
                  ElevatedButton(
                      onPressed: () async {
                            if (_formKey.currentState!.validate()) edit();
                          },
                      child: Text(widget.equipment != null
                          ? ''
                              'Bearbeiten'
                          : 'Hinzufügen')),
                ],
              ),
              TextFormField(
                controller: _controllerBrand,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: 'Hersteller'),
                validator: (value) => EquipmentValidator.brand(value),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _controllerName,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => EquipmentValidator.name(value),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                controller: _controllerWeight,
                decoration: const InputDecoration(labelText: 'Gewicht'),
                validator: (value) => EquipmentValidator.weight(value),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => EquipmentValidator.size(value),
                controller: _controllerSize,
                decoration: const InputDecoration(labelText: 'Größe'),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => EquipmentValidator.priceOrUvp(value.toString().replaceAll(',', '.')),
                controller: _controllerPrice,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preis'),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _controllerUvp,
                keyboardType: TextInputType.number,
                validator: (value) => EquipmentValidator.priceOrUvp(value.toString().replaceAll(',', '.')),
                decoration: const InputDecoration(labelText: 'UVP'),
              ),
              FormField<int>(
                key: _formKeyCount,
                initialValue: widget.equipment?.count ?? 1,
                autovalidateMode: AutovalidateMode.always,
                validator: (value) => EquipmentValidator.categoryOrCount(value),
                builder: (state) => Row(
                  children: [
                    Text(state.value.toString()),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            if (state.value! > 1) state.setValue(state.value! - 1);
                          });
                        },
                        child: const Text('-')),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            state.setValue(state.value! + 1);
                          });
                        },
                        child: const Text('+')),
                  ],
                ),
              ),
              FormField<DateTime?>(
                key: _formKeyDate,
                autovalidateMode: AutovalidateMode.always,
                initialValue: widget.equipment?.purchaseDate,
                validator: (value) => EquipmentValidator.purchaseDate(value),
                builder: (state) => ListTile(
                  trailing: const Icon(Icons.chevron_right_outlined),
                  subtitle: Text(state.errorText ?? 'Kein Fehler'),
                  onTap: () async {
                    final DateTime? d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    setState(() {
                      state.setValue(d);
                    });
                  },
                  title: Text(state.value?.toString() ??
                      'date not definded'),
                ),
              ),
              FormField<List<String>>(
                validator: (value) => EquipmentValidator.sports(value),
                autovalidateMode: AutovalidateMode.always,
                key: _formKeySports,
                initialValue: widget.equipment?.sports ?? <String>[],
                  builder: (state) => ListTile(
                    title: Text(state.value!.isNotEmpty
                        ? state.value!.toString()
                        : 'Sportart'),
                    subtitle: Text(state.errorText ?? 'Kein Fehler'),
                    trailing: const Icon(Icons.chevron_right_outlined),
                    onTap: () async {
                      final List<String> s =
                      await selectSports(context, state.value!);
                      setState(() {
                        state.setValue(s);
                      });
                    },
                  ),),
              FormField<int>(
                validator: (value) => EquipmentValidator.categoryOrCount(value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKeyCategory,
                initialValue: widget.equipment?.category ?? -1,
                builder: (state) => ListTile(
                  subtitle: Text(state.errorText ?? 'Kein Fehler'),
                  title: Text('Kategorie: ${state.value.toString()}'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () async {
                    final int i =
                    await selectCategory(context, state.value!);
                    setState(() {
                      state.setValue(i);
                    });
                  },
                ),
              ),
            ],
          ),
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
  await CustomDialog.showCustomModal(
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
  final TextEditingController _textEditingController = TextEditingController();
  final List<Category> dataCategories = Data.categories;
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
        TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            labelText: 'Suche',
            suffix: IconButton(onPressed: () => _textEditingController.clear(), icon: const Icon(Icons.close))
          ),
          onChanged: (value) {
            dataCategories.where((element) => element.name.toLowerCase().contains(value.toLowerCase()));
          },
        ),
        Expanded(
          child: ListView(
            children: createCategories(dataCategories),
          ),
        )
      ],
    );
  }
}
