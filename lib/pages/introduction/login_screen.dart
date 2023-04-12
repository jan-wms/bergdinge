import 'dart:io';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:equipment_app/custom_widgets/show_custom_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onWaitingStart;
  final VoidCallback onWaitingEnd;

  const LoginScreen(
      {Key? key, required this.onWaitingStart, required this.onWaitingEnd})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Future<void> handleError(Exception exception, BuildContext context) async {
    String message = 'Ein Fehler ist aufgetreten.';

    if (exception.runtimeType == FirebaseAuthException) {
      message = '$message\n[${(exception as FirebaseAuthException).message}]';

      switch (exception.code) {
        case 'internal-error':
          message =
              'Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung.';
          break;
      }
    }

    await CustomDialog.showCustomInformationDialog(
        context: context, description: message);
  }

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await Auth().signInAnonymously();
    } on FirebaseAuthException catch (e) {
      await handleError(e, context);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await Auth().signInWithGoogle(isLinkingAccounts: false);
    } on Exception catch (e) {
      await handleError(e, context);
    }
  }

  bool getIsMacOS() {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Log in'),
              if (!getIsMacOS())
                ElevatedButton(
                    onPressed: () async {
                      widget.onWaitingStart();
                      setState(() {
                        isLoading = true;
                      });
                      await signInWithGoogle(context);
                      setState(() {
                        isLoading = false;
                      });
                      widget.onWaitingEnd();
                    },
                    child: const Text('Sign in with Google')),
              ElevatedButton(
                  onPressed: () {}, child: const Text('Sign in with Apple')),
              ElevatedButton(
                  onPressed: () async {
                    widget.onWaitingStart();
                    setState(() {
                      isLoading = true;
                    });
                    await signInAnonymously(context);
                    setState(() {
                      isLoading = false;
                    });
                    widget.onWaitingEnd();
                  },
                  child: const Text('Continue without sign in')),
            ],
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          )
      ],
    );
  }
}
