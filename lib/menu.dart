import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Entdecken'),
          onTap: () => GoRouter.of(context).go('/'),
        ),
        ListTile(
          title: const Text('Packlisten'),
          onTap: () => GoRouter.of(context).go('/packing_plan'),
        ),
        ListTile(
          title: const Text('Ausrüstung'),
          onTap: () => GoRouter.of(context).go('/equipment'),
        ),
        ListTile(
          title: const Text('Einstellungen'),
          onTap: () => GoRouter.of(context).go('/settings'),
        ),
      ],
    );
  }
}
