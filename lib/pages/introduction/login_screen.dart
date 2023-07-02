import 'dart:async';
import 'dart:io';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sign_in_button/sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final AuthenticationAction authenticationAction;

  const LoginScreen(
      {Key? key, required this.authenticationAction })
      : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _auth = Auth();
  late final StreamSubscription gsiOnUserChanged;

  final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

  Future<void> handleError(
      FirebaseAuthException exception, BuildContext context) async {
    String message = 'Ein Fehler ist aufgetreten.\n[${exception.message}]';

    switch (exception.code) {
      case 'internal-error':
        message =
            'Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung.';
        break;
      case 'user-disabled':
        message =
            'Dieser Account wurde deaktiviert. Bitte wende dich an den Support';
    }
    await CustomDialog.showCustomInformationDialog(
        context: context, description: message);
  }

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      await handleError(e, context);
    }
  }

  bool getIsMacOS() {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();

    gsiOnUserChanged = _auth.gsiOnCurrentUserChanged(authenticationAction: widget.authenticationAction);
    gsiOnUserChanged.onError((e) {
      handleError(e, context);
    });

    if (kIsWeb) {
      _auth.googleSignInSilently();
    }
  }

  @override
  void dispose() {
    super.dispose();
    gsiOnUserChanged.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.authenticationAction == AuthenticationAction.linkAccounts ? 'Mit account verknüpfen' : 'Log in'),
              if (!getIsMacOS())
                buildSignInButton(
                  onPressed: () => _auth.signInWithGoogle(),
                ),
              ElevatedButton(
                  onPressed: () {},
                  child: const Text('Sign in with Apple')),
              if(widget.authenticationAction == AuthenticationAction.signIn)
              ElevatedButton(
                  onPressed: () async {
                    ref.read(isLoadingProvider.notifier).state = true;
                    await signInAnonymously(context);
                    ref.read(isLoadingProvider.notifier).state = false;
                  },
                  child: const Text('Continue without sign in')),
            ],
          ),
        ),
        if (ref.watch(isLoadingProvider))
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
