import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../firebase/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Auth().user?.uid ?? 'kein user',
        ),
        Text(
          Auth().user?.email ?? 'keine email',
        ),
        if(Auth().user?.isAnonymous ?? true) ElevatedButton(
            onPressed: () {
              context.go('/link_accounts');
            },
            child: const Text('Account erstellen')),
        ElevatedButton(
            onPressed: () {
              //TODO implement delete account
            },
            child: const Text('Account löschen')),
        ElevatedButton(
            onPressed: () {
              Auth().signOut();
            },
            child: const Text('sign out')),
      ],
    );
  }
}
