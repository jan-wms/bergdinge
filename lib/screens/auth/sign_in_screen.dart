import 'dart:async';
import 'dart:math';
import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/firebase/firebase_data_providers.dart';
import 'package:bergdinge/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_dialog.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final AuthenticationAction authenticationAction;
  final VoidCallback onComplete;

  const SignInScreen(
      {super.key,
      required this.authenticationAction,
      required this.onComplete});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _auth = Auth();
  bool _isLoading = false;

  Future<void> handleError(
      FirebaseAuthException exception, BuildContext context) async {
    String message = 'Ein Fehler ist aufgetreten.\n[${exception.message}]';
    if (exception.code == 'network-request-failed' || exception.code == 'internal-error') {
      message =
          'Ein Fehler ist aufgetreten. Bitte überprüfe deine Internetverbindung.';
    }
    if (exception.code == 'user-disabled' ||
        (exception.message?.contains('disabled') ?? false)) {
      message =
          'Dieser Account wurde deaktiviert. Bitte wende dich an den Support.';
    }
    if (exception.code == 'popup-closed-by-user') {
      message = 'Der Anmeldevorgang wude abgebrochen.';
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
        setState(() {
          _isLoading = false;
        });
        await handleError(e, context);
      } else {
        debugPrint(
            '[Error] \'signInAnonymously\' failed. Could not show info dialog, context not mounted. ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      constraints: (screenSize.width > Design.wideScreenBreakpoint &&
              widget.authenticationAction != AuthenticationAction.signIn)
          ? BoxConstraints(
              maxWidth: min(
                600,
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
          if (isWide &&
              widget.authenticationAction == AuthenticationAction.signIn)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(40),
                              border:
                                  Border.all(color: Design.darkGreen, width: 3),
                              image: DecorationImage(
                                  image: AssetImage('assets/example.jpg'),
                                  fit: BoxFit.cover)),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 500),
                          padding: const EdgeInsets.only(
                              top: 30.0, bottom: 70, left: 30, right: 30),
                          child: Text(
                            'Erstelle deine eigenen Packlisten und erhalte genaue Gewichtsangaben.',
                            style: TextStyle(
                                color: Design.darkGreen, fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: SvgPicture.asset(
                              'assets/icon.svg',
                              semanticsLabel: 'Bergdinge Icon',
                              height: 15.0,
                              colorFilter: ColorFilter.mode(
                                  Design.darkGreen.withValues(alpha: 0.7),
                                  BlendMode.srcIn),
                            ),
                          ),
                          Text(
                            'Bergdinge',
                            style: TextStyle(
                                color: Design.darkGreen.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: Design.green,
              height: double.infinity,
              alignment: Alignment.center,
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 30.0,
                children: [
                  Text(
                    widget.authenticationAction ==
                            AuthenticationAction.reauthenticate
                        ? 'Identität bestätigen'
                        : 'Anmelden',
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30.0,
                        color: Colors.white),
                  ),
                  Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
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
                                    ref.read(userAuthProvider) == 'google.com'))
                              _SignInButton(
                                signInType: _SignInType.google,
                                onPressed: () async {
                                  final currentContext = context;

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final userCredential =
                                        await _auth.signInWithGoogle(
                                            authenticationAction:
                                                widget.authenticationAction);

                                    if (!currentContext.mounted) return;
                                    if (userCredential != null) {
                                      widget.onComplete();
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (!currentContext.mounted) return;
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    handleError(e, context);
                                  } catch (e) {
                                    if (currentContext.mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                    debugPrint(
                                        "[ERROR] Unknown error on Google SignIn: $e");
                                  }
                                },
                              ),
                            if (widget.authenticationAction !=
                                    AuthenticationAction.reauthenticate ||
                                (widget.authenticationAction ==
                                        AuthenticationAction.reauthenticate &&
                                    ref.read(userAuthProvider) == 'apple.com'))
                              _SignInButton(
                                signInType: _SignInType.apple,
                                onPressed: () =>
                                    CustomDialog.showCustomInformationDialog(
                                        context: context,
                                        description:
                                            'Diese Funktion ist momentan nicht verfügbar.'),
                              ),
                            if (widget.authenticationAction ==
                                AuthenticationAction.signIn)
                              SizedBox(
                                height: 60.0,
                                child: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      await signInAnonymously(context);
                                    },
                                    child: const Text('Überspringen')),
                              ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            alignment: Alignment.center,
                            child: SizedBox(
                                height: 30.0,
                                width: 30.0,
                                child: const CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
                  if (widget.authenticationAction !=
                      AuthenticationAction.signIn)
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

enum _SignInType {
  apple,
  google;
}

class _SignInButton extends StatelessWidget {
  final _SignInType signInType;
  final VoidCallback onPressed;

  const _SignInButton({required this.signInType, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 50,
      decoration: signInType == _SignInType.google
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
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
                signInType == _SignInType.google ? Colors.white : Colors.black,
            foregroundColor: signInType == _SignInType.google
                ? Colors.black54
                : Colors.white,
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
              child: signInType == _SignInType.google
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
              child: Text(signInType == _SignInType.google
                  ? 'Über Google anmelden'
                  : 'Mit Apple anmelden'),
            ),
          ],
        ),
      ),
    );
  }
}
