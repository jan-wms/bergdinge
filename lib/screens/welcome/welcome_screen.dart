import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/firebase/firebase_auth.dart';
import 'package:bergdinge/screens/auth/sign_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utilities/copy_to_clipboard.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _outerPageController = PageController(initialPage: 0);
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  void dispose() {
    _outerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final bool isWide = screenSize.width > Design.wideScreenBreakpoint;

    return Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _outerPageController,
          children: [
            AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.black, // Android
                    statusBarBrightness: Brightness.light // IOS.
                    ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 50.0, bottom: 50.0),
                        child: isWide
                            ? Row(
                                children: [
                                  Expanded(child: Image.asset('assets/onboarding.jpg')),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 70.0),
                                            child: _Message(),
                                          ),
                                          _Button(
                                              onPressed: () =>
                                                  _outerPageController
                                                      .jumpToPage(1)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      constraints: BoxConstraints(
                                        maxWidth: screenSize.height * 0.7,
                                      ),
                                      child: Image.asset('assets/onboarding.jpg')),
                                  Spacer(),
                                  const _Message(),
                                  Spacer(flex: 2),
                                  _Button(
                                      onPressed: () =>
                                          _outerPageController.jumpToPage(1)),
                                ],
                              ),
                      ),
                      Positioned(
                        top: isWide ? null : 0,
                        right: isWide ? null : 0,
                        bottom: isWide ? 0 : null,
                        left: isWide ? 0 : null,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextButton(
                              onPressed: () async {
                                final Uri url =
                                    Uri.parse('https://freepik.com/');
                                launchUrl(url).then((didLaunch) {
                                  if (didLaunch == false && context.mounted) {
                                    copyToClipboard(
                                        context: context,
                                        value: 'https://freepik.com/');
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Image by freepik',
                                    style: TextStyle(
                                        color: Colors.black26, fontSize: 10),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3.0),
                                    child: Icon(
                                      Icons.launch_rounded,
                                      color: Colors.black26,
                                      size: 10,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                )),
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.white, // Android
                  statusBarBrightness: Brightness.dark // IOS.
                  ),
              child: SignInScreen(
                  authenticationAction: AuthenticationAction.signIn,
                  onComplete: () {}),
            ),
          ],
        ));
  }
}

class _Message extends StatelessWidget {
  const _Message();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400.0,
      ),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Dein Abenteuer beginnt hier.',
              style: TextStyle(
                height: 1.1,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Behalte mit der Bergdinge App deine Bergsport Ausrüstung im Überblick.',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final VoidCallback onPressed;

  const _Button({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
          foregroundColor: Colors.white,
          backgroundColor: Design.green,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 30,
        width: 200,
        child: const Text(
          'Entdecken',
          style: TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}
