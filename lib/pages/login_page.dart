import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await Auth().signInAnonymously();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controllerEmail,
            ),
            TextField(
              controller: _controllerPassword,
            ),
            ElevatedButton(
                onPressed: () {
                  signInWithEmailAndPassword();
                },
                child: const Text('sign in')),
            ElevatedButton(
                onPressed: () {
                  signInAnonymously();
                },
                child: const Text('continue without sign in')),
          ],
        )),
      ),
    );
  }
}
