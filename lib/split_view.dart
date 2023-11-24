import 'package:equipment_app/data/design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'menu.dart';

class SplitView extends StatefulWidget {
  const SplitView({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > Design.breakpoint) {
      return Scaffold(
        body: Row(
          children: [
            const SizedBox(
              width: 250,
              child: Menu(),
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Entdecken'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Packlisten'),
            BottomNavigationBarItem(icon: Icon(Icons.backpack), label: 'Ausrüstung'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Einstellungen'),
          ],
          currentIndex: tabIndex,
          onTap: (int index) {
            setState(() {
              tabIndex = index;
            });
            switch (index) {
              case 0:
                GoRouter.of(context).go('/');
                break;
              case 1:
                GoRouter.of(context).go('/packing_plan');
                break;
              case 2:
                GoRouter.of(context).go('/equipment');
                break;
              case 3:
                GoRouter.of(context).go('/settings');
                break;
              default:
                GoRouter.of(context).go('/');
                break;
            }
          },
        ),
      );
    }
  }
}
