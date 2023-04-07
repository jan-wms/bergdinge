import 'dart:io';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  bool getIsMacOS () {
    if(kIsWeb) return false;
    return Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Auth().user != null ? 'Mit Account verknüpfen.' : 'Log in'),
            TextField(
              controller: _controllerEmail,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Passwort'),
              controller: _controllerPassword,
            ),
            ElevatedButton(
                onPressed: () => signInWithEmailAndPassword(),
                child: const Text('sign in')),
            if(!getIsMacOS()) ElevatedButton(
                onPressed: () => signInWithGoogle(),
                child: const Text('sign in with google')),
            if(Auth().user == null) ElevatedButton(
                onPressed: () => signInAnonymously(),
                child: const Text('continue without sign in')),
          ],
        )),
      ),
    );
  }
}
