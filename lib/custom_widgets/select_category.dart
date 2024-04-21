import 'package:flutter/material.dart';

import '../data/data.dart';
import '../data_models/category.dart';
import 'custom_dialog.dart';

Future<String> selectCategory(BuildContext context, String selected) async {
  final GlobalKey<_SelectCategoryState> k = GlobalKey();
  final SelectCategory selectCategory = SelectCategory(
    key: k,
    selected: selected,
  );
  await CustomDialog.showCustomModal(
    context: context,
    child: selectCategory,
  );
  return k.currentState!.selected;
}

class SelectCategory extends StatefulWidget {
  final String selected;

  const SelectCategory({super.key, required this.selected});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<Category> dataCategories = Data.categories;
  late String selected = widget.selected;

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
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
              labelText: 'Suche',
              suffix: IconButton(
                  onPressed: () => _textEditingController.clear(),
                  icon: const Icon(Icons.close))),
          onChanged: (value) {
            dataCategories.where((element) =>
                element.name.toLowerCase().contains(value.toLowerCase()));
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
