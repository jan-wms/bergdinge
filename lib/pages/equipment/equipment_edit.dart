import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_back_button.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data/data.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/validators/equipment_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/select_category.dart';
import '../../data/design.dart';
import '../../firebase/firebase_auth.dart';

class EquipmentEdit extends ConsumerStatefulWidget {
  final Equipment? equipment;

  const EquipmentEdit({super.key, this.equipment});

  @override
  ConsumerState<EquipmentEdit> createState() => _EquipmentEditState();
}

class _EquipmentEditState extends ConsumerState<EquipmentEdit> {
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _formKeyCount = GlobalKey<FormFieldState>();
  final _formKeyDate = GlobalKey<FormFieldState>();
  final _formKeyCategory = GlobalKey<FormFieldState>();

  late final TextEditingController _controllerName =
      TextEditingController(text: widget.equipment?.name ?? '');
  late final TextEditingController _controllerBrand =
      TextEditingController(text: widget.equipment?.brand ?? '');
  late final TextEditingController _controllerWeight =
      TextEditingController(text: (widget.equipment?.weight ?? '').toString());
  late final TextEditingController _controllerPrice =
      TextEditingController(text: (widget.equipment?.price ?? '').toString());
  late final TextEditingController _controllerSize =
      TextEditingController(text: widget.equipment?.size ?? '');
  late final TextEditingController _controllerUvp =
      TextEditingController(text: (widget.equipment?.uvp ?? '').toString());

  void edit({required List<Equipment>? equipmentList}) async {
    setState(() {
      isLoading = true;
    });
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

    bool continueEdit = true;
    final int? duplicate = equipmentList?.indexWhere((element) =>
        element.name.toLowerCase() == e.name.toLowerCase() &&
        element.id != e.id);
    if (duplicate != null && duplicate != -1) {
      await CustomDialog.showCustomConfirmationDialog(
              context: context,
              description:
                  'Es existiert bereits ein Gegenstand mit dem Namen "${equipmentList!.elementAt(duplicate).name}". Trotzdem fortfahren?')
          .then((value) {
        if (!value) {
          continueEdit = false;
          setState(() {
            isLoading = false;
          });
        }
      });
    }

    if (continueEdit) {
      await ref.set(e.toMap()).then((value) => context.pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            'Gegenstand ${widget.equipment != null ? 'bearbeiten' : 'hinzufügen'}'),
        actions: [
          FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && !isLoading) {
                  edit(equipmentList: ref.read(equipmentStreamProvider).value);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Design.colors[1],
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              child: SizedBox(
                width: 30,
                height: 30,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white54,
                      )
                    : const Icon(Icons.check_rounded),
              )),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: Design.pagePadding,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                  FormField<String>(
                    validator: (value) => EquipmentValidator.category(value),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKeyCategory,
                    initialValue: widget.equipment?.category ?? '-1',
                    builder: (state) => ListTile(
                      subtitle: Text(state.errorText ?? 'Kein Fehler'),
                      title: Text('Kategorie: ${state.value.toString()}'),
                      trailing: const Icon(Icons.chevron_right_outlined),
                      onTap: () async {
                        final String i =
                            await selectCategory(context, state.value!);
                        state.didChange(i);
                      },
                    ),
                  ),
                  FormField<int>(
                    key: _formKeyCount,
                    initialValue: widget.equipment?.count ?? 1,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) => EquipmentValidator.count(value),
                    builder: (state) => Row(
                      children: [
                        Text(state.value.toString()),
                        TextButton(
                            onPressed: () {
                              if (state.value! > 1) {
                                state.didChange(state.value! - 1);
                              }
                            },
                            child: const Text('-')),
                        TextButton(
                            onPressed: () {
                              state.didChange(state.value! + 1);
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
                        state.didChange(d);
                      },
                      title: Text(state.value?.toString() ?? 'date not definded'),
                    ),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => EquipmentValidator.priceOrUvp(
                        value.toString().replaceAll(',', '.')),
                    controller: _controllerPrice,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Preis'),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _controllerUvp,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => EquipmentValidator.priceOrUvp(
                        value.toString().replaceAll(',', '.')),
                    decoration: const InputDecoration(labelText: 'UVP'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
