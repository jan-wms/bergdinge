import 'dart:async';
import 'dart:math';
import 'package:equipment_app/data/design.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_dialog.dart';
import './sign_in_button/sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final AuthenticationAction authenticationAction;
  final VoidCallback onComplete;

  const LoginScreen(
      {super.key,
      required this.authenticationAction,
      required this.onComplete});

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
    Size screenSize = MediaQuery.of(context).size;
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      constraints: (screenSize.width > Design.breakpoint1 &&
              widget.authenticationAction != AuthenticationAction.signIn)
          ? BoxConstraints(
              maxWidth: min(
                1200,
                screenSize.width * 0.7,
              ),
              maxHeight: min(
                700,
                screenSize.width * 0.7,
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDesktop)
            Expanded(
              child: Hero(
                tag: 'onboarding',
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.asset('assets/mountain.jpg').image,
                        alignment: Alignment.bottomCenter,
                        fit: BoxFit.cover),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(50.0),
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SvgPicture.asset(
                            'assets/icon.svg',
                            semanticsLabel: 'Bergdinge Icon',
                            height: 30.0,
                          ),
                        ),
                        const Text(
                          'Bergdinge',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Container(
              color: Design.colors[1],
              height: double.infinity,
              alignment: Alignment.center,
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 30.0,
                children: [
                  const Text(
                    'Anmelden',
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 40.0,
                        color: Colors.white),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.only(
                        bottom: 30.0,
                        left: 30.0,
                        right: 30.0,
                        top: (widget.authenticationAction ==
                                AuthenticationAction.signIn)
                            ? 50.0
                            : 30.0),
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
                          SignInButton(
                            signInType: SignInType.apple,
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
                                    onPressed: () async {
                                      ref
                                          .read(isLoadingProvider.notifier)
                                          .state = true;
                                      await signInAnonymously(context);
                                      ref
                                          .read(isLoadingProvider.notifier)
                                          .state = false;
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
      ),
    );
  }
}

enum SignInType {
  apple,
  google;
}

class SignInButton extends StatelessWidget {
  final SignInType signInType;
  final VoidCallback? onPressed;

  const SignInButton(
      {super.key, required this.signInType, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 50,
      decoration: signInType == SignInType.google
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            )
          : null,
      child: FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor:
                signInType == SignInType.google ? Colors.white : Colors.black,
            foregroundColor:
                signInType == SignInType.google ? Colors.black54 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(15),
            //padding: EdgeInsets.zero,
            textStyle: const TextStyle(fontSize: 16),
            splashFactory: NoSplash.splashFactory),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 25,
              height: 25,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: signInType == SignInType.google
                  ? Image.asset('assets/google.png')
                  : Transform.translate(
                      offset: const Offset(-3, -6),
                      child: const Icon(
                        Icons.apple,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 11),
              child: Text(signInType == SignInType.google
                  ? 'Über Google anmelden'
                  : 'Mit Apple anmelden'),
            ),
          ],
        ),
      ),
    );
  }
}
