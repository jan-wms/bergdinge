import 'dart:async';
import 'package:equipment_app/data/design.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> handleError(
      FirebaseAuthException exception, BuildContext context) async {
    String message = 'Ein Fehler ist aufgetreten.\n[${exception.message}]';

    if (exception.code == 'internal-error') {
      message =
          'Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung.';
    }
    if (exception.code == 'user-disabled' ||
        (exception.message?.contains('disabled') ?? false)) {
      message =
          'Dieser Account wurde deaktiviert. Bitte wende dich an den Support.';
    }
    if (exception.code == 'user-mismatch' ||
        (exception.message?.contains('user-mismatch') ?? false)) {
      message =
          'Bitte melde dich mit deinem Account ${_auth.user?.email} erneut an.';
    }
    if (exception.message?.contains(
            'This credential is already associated with a different user account.') ??
        false) {
      message = 'Dieser Account wird bereits bei Bergdinge verwendet.';
    }

    await CustomDialog.showCustomInformationDialog(
        context: context, description: message);
  }

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        await handleError(e, context);
      } else {
        debugPrint('not mounted');
      }
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: Image.asset('assets/1.jpg').image, alignment: Alignment.bottomCenter, fit: BoxFit.cover),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(50.0),
            width: double.infinity,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: SizedBox(
                      height: 50.0,
                      child: Image.asset('assets/icon.png')),
                ),
                const Text(
                      'Bergdinge',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 70.0),
                    ),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Container(
            color: Design.colors[1],
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            child: Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 30.0,
              children: [
                if(false)
                Text(
                  widget.authenticationAction ==
                          AuthenticationAction.linkAccounts
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
                  padding: const EdgeInsets.only(bottom: 30.0, left: 30.0, right: 30.0, top: 50.0),
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
                                  description:
                                      'Diese Funktion ist momentan nicht verfügbar.')
                              : null,
                        ),
                      if (widget.authenticationAction ==
                          AuthenticationAction.signIn)
                        SizedBox(
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
                                    ref.read(isLoadingProvider.notifier).state =
                                        true;
                                    await signInAnonymously(context);
                                    ref.read(isLoadingProvider.notifier).state =
                                        false;
                                  },
                                  child: const Text('Überspringen')),
                        ),
                    ],
                  ),
                ),
                if (context.canPop())
                  TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Abbrechen',
                        style: TextStyle(color: Colors.white),
                      )),
              ],
            ),
          ),
        ),
      ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            splashFactory: NoSplash.splashFactory),
        onPressed: () => onPressed(),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              IconData(0xf02d8, fontFamily: 'MaterialIcons'),
              size: 30,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
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
