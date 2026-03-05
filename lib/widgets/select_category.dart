import 'package:bergdinge/data/category_data.dart';
import 'package:flutter/material.dart';

import '../data/design.dart';
import '../models/category.dart';

class SelectCategory extends StatefulWidget {
  final String selected;

  const SelectCategory({super.key, required this.selected});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  final List<Category> dataCategories = CategoryData.categories;
  late String selected = widget.selected;

  final List<Category> categoryStack = [];

  List<Category> get currentCategories => categoryStack.isEmpty
      ? CategoryData.categories
      : categoryStack.last.subCategories ?? [];

  Widget _buildCategoryList() {
    return ListView.builder(
        key: const ValueKey('list'),
        itemCount: currentCategories.length,
        itemBuilder: (context, i) {
          final category = currentCategories[i];
          return ListTile(
            title: Text(category.name),
            onTap: () {
              if (category.subCategories?.isEmpty ?? true) {
                setState(() {
                  selected = category.id;
                });
              } else {
                setState(() {
                  categoryStack.add(category);
                });
              }
            },
            trailing: category.id == selected
                ? Icon(
                    Icons.check_circle_outline_rounded,
                    color: Design.green,
                  )
                : category.subCategories?.isNotEmpty ?? false
                    ? const Icon(Icons.chevron_right_rounded)
                    : null,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    if (widget.selected != '-1') {
      categoryStack.addAll(CategoryData.flatMapCategories(widget.selected));
      categoryStack.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > Design.wideScreenBreakpoint;
    return Container(
      constraints: (isWide)
          ? const BoxConstraints(
              maxWidth: 600,
              maxHeight: 650,
            )
          : null,
      padding: (isWide)
          ? const EdgeInsets.only(top: 30.0, left: 40, right: 40, bottom: 20)
          : Design.pagePadding.copyWith(bottom: 40.0, top: 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: const Text(
              'Kategorie wählen',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (categoryStack.isNotEmpty)
                  IconButton(
                      onPressed: () => setState(() {
                            categoryStack.removeLast();
                          }),
                      icon: const Icon(Icons.arrow_back_rounded)),
                for (Category c in categoryStack) ...[
                  Flexible(
                    child: Text(
                      c.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (c.id != categoryStack.last.id)
                    Icon(Icons.chevron_right_rounded)
                ]
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCategoryList(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                foregroundColor: Colors.white,
                backgroundColor: Design.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            onPressed: () => Navigator.of(context).pop(selected),
            child: Container(
              alignment: Alignment.center,
              height: 30,
              width: 105,
              child: Text(
                'Fertig',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
