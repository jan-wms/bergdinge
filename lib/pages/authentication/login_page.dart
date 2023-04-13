import 'dart:io';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final bool isLinkingAccounts;
  const LoginPage({Key? key, required this.isLinkingAccounts}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  Future<void> signInWithEmailAndPassword(bool isLinkingAccounts) async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text, isLinkingAccounts: isLinkingAccounts);
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

  Future<void> signInWithGoogle(bool isLinkingAccounts) async {
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
            Text(widget.isLinkingAccounts ? 'Mit Account verknüpfen.' : 'Log in'),
            Form(
              key: _formKey,
                child: Column (
                  children: [
                    TextFormField(
                      validator: (value) {
                        if(value == null || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) return "Bitte gib eine gültige E-Mail-Adresse ein.";
                        return null;
                      },
                      controller: _controllerEmail,
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                    ),
                    TextFormField(
                      validator: (value) {
                        if(value == null || value.isEmpty) return "Bitte gib ein Passwort ein.";
                        if(value.length < 6) return "Das Passwort muss mindestens 6 Zeichen haben.";
                        return null;
                      },
                      obscureText: obscurePassword,
                      decoration:  InputDecoration(labelText: 'Passwort',
                        suffixIcon: IconButton(icon: obscurePassword ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off), onPressed: () {
                         setState(() {
                           obscurePassword = !obscurePassword;
                         });
                        },),
                      ),
                      controller: _controllerPassword,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) signInWithEmailAndPassword(widget.isLinkingAccounts);
                        },
                        child: const Text('sign in')),
                  ],
                ),
            ),
            if(!getIsMacOS()) ElevatedButton(
                onPressed: () => signInWithGoogle(widget.isLinkingAccounts),
                child: const Text('Sign in with Google')),
            if(!widget.isLinkingAccounts) ElevatedButton(
                onPressed: () => signInAnonymously(),
                child: const Text('Continue without sign in')),
          ],
        )),
      ),
    );
  }
}
