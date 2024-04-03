import 'package:flutter/material.dart';

enum SampleItem { edit, delete }

class MenuAnchorExample extends StatefulWidget {
  const MenuAnchorExample({super.key});

  @override
  State<MenuAnchorExample> createState() => _MenuAnchorExampleState();
}

class _MenuAnchorExampleState extends State<MenuAnchorExample> {
  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MenuAnchor(
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_horiz),
              tooltip: 'Show menu',
            );
          },
          menuChildren: List<MenuItemButton>.generate(
            3,
                (int index) => MenuItemButton(
              onPressed: () =>
                  setState(() => selectedMenu = SampleItem.values[index]),
              child: Text('Item ${index + 1}'),
            ),
          ),
        ),
    );
  }
}
