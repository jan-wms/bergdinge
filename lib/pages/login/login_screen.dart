import 'dart:async';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_dialog.dart';
import './sign_in_button/sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final AuthenticationAction authenticationAction;
  final VoidCallback onComplete;

  const LoginScreen(
      {Key? key, required this.authenticationAction, required this.onComplete})
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
    if (exception.code == 'user-mismatch' ||
        (exception.message?.contains('user-mismatch') ?? false)) {
      message = 'Bitte melde dich mit deinem Account email@mail.de erneut an.';
    }
    if (exception.message?.contains(
            'This credential is already associated with a different user account.') ??
        false) {
      message = 'Dieser Account wird bereits verwendet.';
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
    return Center(
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 30.0,
        children: [
          Text(
            widget.authenticationAction == AuthenticationAction.linkAccounts
                ? 'Mit Account verknüpfen'
                : widget.authenticationAction ==
                        AuthenticationAction.reauthenticate
                    ? 'Bitte melden Sie sich erneut an.'
                    : 'Anmelden',
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 40.0,
                color: Colors.white),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(30.0),
            child: Wrap(
              spacing: 20.0,
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (widget.authenticationAction !=
                            AuthenticationAction.reauthenticate ||
                        (widget.authenticationAction ==
                                AuthenticationAction.reauthenticate &&
                            ref.read(authProvider) == 'google.com'))
                  buildSignInButton(
                    onPressed: () => _auth.signInWithGoogle(),
                  ),
                if (widget.authenticationAction !=
                        AuthenticationAction.reauthenticate ||
                    (widget.authenticationAction ==
                            AuthenticationAction.reauthenticate &&
                        ref.read(authProvider) == 'apple.com'))
                  _SignInWithAppleButton(
                    onPressed: () => (!ref.watch(isLoadingProvider))
                        ? CustomDialog.showCustomInformationDialog(
                            context: context,
                            description: 'Diese Funktion ist nicht verfügbar.')
                        : null,
                  ),
                if (widget.authenticationAction == AuthenticationAction.signIn)
                  Container(
                    height: 60.0,
                    child: (ref.watch(isLoadingProvider))
                        ? Container(
                            margin: const EdgeInsets.all(15.0),
                            height: 30.0,
                            width: 30.0,
                            child: const CircularProgressIndicator())
                        : TextButton(
                            style: TextButton.styleFrom(
                                //foregroundColor: Colors.white
                                ),
                            onPressed: () async {
                              ref.read(isLoadingProvider.notifier).state = true;
                              await signInAnonymously(context);
                              ref.read(isLoadingProvider.notifier).state =
                                  false;
                            },
                            child: const Text('Überspringen')),
                  ),
              ],
            ),
          ),
          Visibility(
            visible: ref.watch(errorMessageProvider).isNotEmpty,
            child: Text(
              ref.watch(errorMessageProvider),
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
              ),
            ),
          ),
          if (context.canPop())
            TextButton(
                onPressed: () => context.pop(), child: const Text('Abbrechen')),
        ],
      ),
    );
  }
}

class _SignInWithAppleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignInWithAppleButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            splashFactory: NoSplash.splashFactory),
        onPressed: () => onPressed(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 25,
                height: 25,
                child: Image.asset('assets/appleIcon.png')),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Mit Apple anmelden',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
