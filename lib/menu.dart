import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/design.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black12,
      child: ListView(
        children: [
          Text(
              'Hallo ${ref.watch(userDataStreamProvider).value?['name'] ?? ''}!'),
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_rounded),
                if (screenWidth > Design.breakpoint2) const Text('Entdecken'),
              ],
            ),
            onTap: () => GoRouter.of(context).go('/'),
          ),
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.checklist_rounded),
                if (screenWidth > Design.breakpoint2) const Text('Packlisten'),
              ],
            ),
            onTap: () => GoRouter.of(context).go('/packing_plan'),
          ),
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.backpack_rounded),
                if (screenWidth > Design.breakpoint2) const Text('Ausrüstung'),
              ],
            ),
            onTap: () => GoRouter.of(context).go('/equipment'),
          ),
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded),
                if (screenWidth > Design.breakpoint2) const Text('Profil'),
              ],
            ),
            onTap: () => GoRouter.of(context).go('/settings'),
          ),
          if (kIsWeb &&
              !(ref.watch(userChangesProvider).value?.isAnonymous ?? true))
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout_outlined),
                  if (screenWidth > Design.breakpoint2) const Text('Abmelden'),
                ],
              ),
              onPressed: () => Auth().signOut(),
            ),
        ],
      ),
    );
  }
}
