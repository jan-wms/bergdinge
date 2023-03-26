import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? _user = Auth().user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Home',
          ),
          Text(
            _user?.uid ?? 'kein user',
          ),
          ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/equipment');
              },
              child: const Text('go to equipment')),
          ElevatedButton(
              onPressed: () {
                Auth().signOut();
              },
              child: const Text('sign out')),
        ],
      ),
    );
  }
}
