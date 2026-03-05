import 'package:bergdinge/data/category_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bergdinge/widgets/custom_dialog.dart';
import 'package:bergdinge/firebase/firebase_data_providers.dart';
import 'package:bergdinge/models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utilities/parser.dart';
import '../../widgets/select_category.dart';
import '../../data/design.dart';
import '../../firebase/firebase_auth.dart';

class EquipmentEdit extends ConsumerStatefulWidget {
  final Equipment? equipment;

  const EquipmentEdit({super.key, this.equipment});

  @override
  ConsumerState<EquipmentEdit> createState() => _EquipmentEditState();
}

class _EquipmentEditState extends ConsumerState<EquipmentEdit> {
  bool _isLoading = false;
  int _currentPage = 0;
  late String _selectedCategory = widget.equipment?.category ?? '-1';

  final _formKey = GlobalKey<FormState>();
  final _formKeyCount = GlobalKey<FormFieldState>();
  final _formKeyDate = GlobalKey<FormFieldState>();
  final _formKeyCategory = GlobalKey<FormFieldState>();
  final _pageController = PageController(initialPage: 0);

  late final TextEditingController _controllerName =
      TextEditingController(text: widget.equipment?.name ?? '');
  late final TextEditingController _controllerBrand =
      TextEditingController(text: widget.equipment?.brand ?? '');
  late final TextEditingController _controllerWeight =
      TextEditingController(text: (widget.equipment?.category == '3.0') ? '1' : (widget.equipment?.weight ?? '').toString());
  late final TextEditingController _controllerPrice =
      TextEditingController(text: (widget.equipment?.price ?? '').toString());
  late final TextEditingController _controllerSize =
      TextEditingController(text: widget.equipment?.size ?? '');
  late final TextEditingController _controllerUvp =
      TextEditingController(text: (widget.equipment?.uvp ?? '').toString());

  void edit({required List<Equipment>? equipmentList}) async {
    setState(() {
      _isLoading = true;
    });
    DocumentReference ref = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().user?.uid)
        .collection('equipment')
        .doc(widget.equipment?.id);

    Equipment e = Equipment(
      name: _controllerName.text,
      weight: int.parse(_controllerWeight.text),
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
    );

    bool continueEdit = true;
    final int? duplicate = equipmentList?.indexWhere((element) =>
        element.name.toLowerCase() == e.name.toLowerCase() &&
        element.id != e.id);
    if (duplicate != null && duplicate != -1) {
      final value = await CustomDialog.showCustomConfirmationDialog(
          type: ConfirmType.confirmContinue,
          context: context,
          description:
              'Es existiert bereits ein Gegenstand mit dem Namen "${equipmentList!.elementAt(duplicate).name}". Trotzdem fortfahren?');

      if (!(value ?? false)) {
        continueEdit = false;
        setState(() {
          _isLoading = false;
        });
      }
    }

    if (continueEdit) {
      await ref.set(e.toMap());

      if (!mounted) return;
      context.pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: (MediaQuery.of(context).size.width > Design.wideScreenBreakpoint)
            ? const BoxConstraints(
                maxWidth: 600,
                maxHeight: 650,
              )
            : null,
        padding: (MediaQuery.of(context).size.width > Design.wideScreenBreakpoint)
            ? const EdgeInsets.only(top: 30.0, left: 40, right: 40, bottom: 20)
            : Design.pagePadding.copyWith(bottom: 40.0, top: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Ausrüstung',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (i) {
                    setState(() {
                      _currentPage = i;
                    });
                  },
                  children: [
                    _KeepAliveWrapper(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: TextFormField(
                                controller: _controllerBrand,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                    labelText: 'Hersteller (Optional)'),
                                validator: (value) =>
                                    Equipment.validateBrand(value),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: _controllerName,
                                decoration:
                                    const InputDecoration(labelText: 'Name'),
                                validator: (value) =>
                                    Equipment.validateName(value),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: TextFormField(
                                enabled: _selectedCategory != '3.0',
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                controller: _controllerWeight,
                                decoration: const InputDecoration(
                                    labelText: 'Gewicht in Gramm'),
                                validator: (value) =>
                                    Equipment.validateWeight(value),
                              ),
                            ),
                            FormField<String>(
                              validator: (value) =>
                                  Equipment.validateCategory(value),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              key: _formKeyCategory,
                              initialValue: widget.equipment?.category ?? '-1',
                              builder: (state) => Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: state.hasError
                                            ? Colors.red
                                            : Colors.black,
                                        width: 0.7),
                                    borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.only(top: 15),
                                child: ListTile(
                                  textColor: state.hasError ? Colors.red : null,
                                  iconColor: state.hasError ? Colors.red : null,
                                  subtitle: (state.value.toString() != '-1' ||
                                          state.hasError)
                                      ? Text(
                                          state.errorText ?? 'Kategorie',
                                        )
                                      : null,
                                  title: Text(
                                    state.value.toString() == '-1'
                                        ? 'Kategorie wählen'
                                        : CategoryData.flatMapCategories(
                                                state.value.toString())
                                            .last
                                            .name,
                                  ),
                                  trailing:
                                      const Icon(Icons.chevron_right_outlined),
                                  onTap: () async {
                                    final String i = await CustomDialog.showCustomModal<String>(
                                      context: context,
                                      child: SelectCategory(
                                        selected: state.value!,
                                      ),
                                    );
                                    state.didChange(i);
                                    setState(() {
                                      _selectedCategory = i;
                                      if(i == '3.0') {
                                        _controllerWeight.text = '1';
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _KeepAliveWrapper(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) =>
                                    Equipment.validateSize(value),
                                controller: _controllerSize,
                                decoration: const InputDecoration(
                                    labelText: 'Größe (Optional)'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) => Equipment.validatePrice(
                                    value.toString().replaceAll(',', '.')),
                                controller: _controllerPrice,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                    labelText: 'Preis (Optional)'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: _controllerUvp,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) => Equipment.validatePrice(
                                    value.toString().replaceAll(',', '.')),
                                decoration: const InputDecoration(
                                    labelText: 'UVP (Optional)'),
                              ),
                            ),
                            FormField<DateTime?>(
                              key: _formKeyDate,
                              autovalidateMode: AutovalidateMode.always,
                              initialValue: widget.equipment?.purchaseDate,
                              validator: (value) =>
                                  Equipment.validatePurchaseDate(value),
                              builder: (state) => Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: state.hasError
                                            ? Colors.red
                                            : Colors.black,
                                        width: 0.7),
                                    borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.only(top: 15),
                                child: ListTile(
                                  textColor: state.hasError ? Colors.red : null,
                                  iconColor: state.hasError ? Colors.red : null,
                                  trailing:
                                      const Icon(Icons.chevron_right_outlined),
                                  subtitle:
                                      (state.value != null || state.hasError)
                                          ? Text(
                                              state.errorText ?? 'Kaufdatum',
                                            )
                                          : null,
                                  onTap: () async {
                                    final DateTime? d = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now(),
                                    );
                                    state.didChange(d);
                                  },
                                  title: Text(state.value != null
                                      ? Parser.stringFromDateTime(state.value!)
                                      : 'Kaufdatum (Optional)'),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 0.7),
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              padding: const EdgeInsets.all(8.0),
                              child: FormField<int>(
                                key: _formKeyCount,
                                initialValue: widget.equipment?.count ?? 1,
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) =>
                                    Equipment.validateCount(value),
                                builder: (state) => Row(
                                  children: [
                                    Expanded(child: Text('Anzahl')),
                                    IconButton(
                                      onPressed: () {
                                        if (state.value! > 1) {
                                          state.didChange(state.value! - 1);
                                        }
                                      },
                                      icon: Icon(Icons.chevron_left_rounded),
                                    ),
                                    Text(state.value.toString()),
                                    IconButton(
                                      onPressed: () {
                                        state.didChange(state.value! + 1);
                                      },
                                      icon: Icon(Icons.chevron_right_rounded),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 400.0,
                ),
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (!_isLoading) {
                            if (_currentPage == 0) {
                              context.pop(false);
                            } else {
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                        ),
                        child: Text(
                          _currentPage == 0 ? 'Abbrechen' : 'Zurück',
                          style: TextStyle(fontSize: 17),
                        )),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          foregroundColor: Colors.white,
                          backgroundColor: Design.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      onPressed: () async {
                        if (_currentPage == 0) {
                          if (_formKey.currentState!.validate()) {
                            _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease);
                          }
                        } else if (_formKey.currentState!.validate() &&
                            !_isLoading) {
                          edit(
                              equipmentList:
                                  ref.read(equipmentStreamProvider).value);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 105,
                        child: _isLoading
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  color: Colors.white54,
                                ),
                              )
                            : Text(
                                _currentPage == 0
                                    ? 'Weiter'
                                    : widget.equipment != null
                                        ? 'Bearbeiten'
                                        : 'Hinzufügen',
                                style: const TextStyle(fontSize: 17),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
