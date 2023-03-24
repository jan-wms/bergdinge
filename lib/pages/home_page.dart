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
  final User? _user = Auth().currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Home',
            ),
            Text(
              _user?.uid ?? '_user',
            ),
            ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/page2');
                },
                child: const Text('go to page 2')),
            ElevatedButton(
                onPressed: () {
                  Auth().signOut();
                },
                child: const Text('sign out')),
          ],
        ),
      ),
    );
  }
}
