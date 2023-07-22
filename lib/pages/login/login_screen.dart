import 'dart:async';
import 'dart:io';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './sign_in_button/sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final AuthenticationAction authenticationAction;
  final VoidCallback onComplete;

  const LoginScreen({Key? key, required this.authenticationAction, required this.onComplete})
      : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _auth = Auth();
  late final StreamSubscription gsiOnUserChanged;

  final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
  final errorMessageProvider = StateProvider.autoDispose<String>((ref) => '');

  Future<void> handleError(
      FirebaseAuthException exception, BuildContext context) async {
    String message = 'Ein Fehler ist aufgetreten.\n[${exception.message}]';

    if (exception.code == 'internal-error') {
      message =
          'Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung.';
    }
    if (exception.code == 'user-disabled') {
      message =
          'Dieser Account wurde deaktiviert. Bitte wende dich an den Support';
    }
    if (exception.code == 'user-mismatch' || (exception.message?.contains('user-mismatch') ?? false)) {
      message = 'Bitte melde dich mit deinem Account email@mail.de erneut an.';
    }

    ref.read(errorMessageProvider.notifier).state = message;
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

    gsiOnUserChanged = _auth.gsiOnCurrentUserChanged(
        authenticationAction: widget.authenticationAction);
    gsiOnUserChanged.onError((e) {
      handleError(e, context);
    });

    gsiOnUserChanged.onData((data) {
      widget.onComplete();
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
              Text(widget.authenticationAction ==
                      AuthenticationAction.linkAccounts
                  ? 'Mit Account verknüpfen'
                  : widget.authenticationAction ==
                          AuthenticationAction.reauthenticate
                      ? 'Bitte melden Sie sich erneut an.'
                      : 'Anmelden'),

              /*if (!getIsMacOS() &&
                  (widget.authenticationAction !=
                          AuthenticationAction.reauthenticate ||
                      (widget.authenticationAction ==
                              AuthenticationAction.reauthenticate &&
                          Auth().user?.providerData.single.providerId ==
                              'google.com')))*/
              buildSignInButton(
                onPressed: () => _auth.signInWithGoogle(),
              ),
              /*if (widget.authenticationAction !=
                      AuthenticationAction.reauthenticate ||
                  (widget.authenticationAction ==
                          AuthenticationAction.reauthenticate &&
                      Auth().user!.providerData.indexWhere(
                              (element) => element.providerId == 'apple.com') >
                          -1))*/
              ElevatedButton(
                  onPressed: () {}, child: const Text('Sign in with Apple')),
              if (widget.authenticationAction == AuthenticationAction.signIn)
                ElevatedButton(
                    onPressed: () async {
                      ref.read(isLoadingProvider.notifier).state = true;
                      await signInAnonymously(context);
                      ref.read(isLoadingProvider.notifier).state = false;
                    },
                    child: const Text('Continue without sign in')),
              Text(
                ref.watch(errorMessageProvider),
                style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                ),
              ),
              if(context.canPop())
                TextButton(onPressed: () => context.pop(), child: const Text('Abbrechen')),
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
