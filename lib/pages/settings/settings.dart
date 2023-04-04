import 'package:flutter/material.dart';

import '../../firebase/firebase_auth.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Auth().user?.uid ?? 'kein user',
        ),
        ElevatedButton(
            onPressed: () {
              Auth().signOut();
            },
            child: const Text('sign out')),
      ],
    );
  }
}
