import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black12,
      child: ListView(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: ref.watch(profilePictureStreamProvider).value,
          ),
          Text('Hallo ${ref.watch(userDataStreamProvider).value?['name']}!'),
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
          if (kIsWeb)
            ElevatedButton(
              child: const Text('Sign out'),
              onPressed: () => Auth().signOut(),
            ),
        ],
      ),
    );
  }
}
