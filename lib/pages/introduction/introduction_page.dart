import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/firebase/firebase_auth.dart';
import 'package:bergdinge/pages/login/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _outerPageController = PageController(initialPage: 0);
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool isDesktop = screenSize.width > 800;

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
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 50.0, bottom: 50.0),
                    child: isDesktop
                        ? Row(
                              children: [
                                const Expanded(child: _Image()),
                                Expanded(
                                  child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child:  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 70.0),
                                        child: _Message(),
                                      ),
                                      _Button(
                                          onPressed: () =>
                                              _outerPageController.jumpToPage(1)),
                                    ],
                                  ),
                                ),),
                              ],
                        )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Container(
                                 constraints: BoxConstraints(
                                   maxWidth: screenSize.height * 0.7,
                                 ),
                                  child: const _Image()),
                              Expanded(child: Container()),
                              const _Message(),
                              Expanded(flex: 2, child: Container()),
                              _Button(
                                  onPressed: () =>
                                      _outerPageController.jumpToPage(1)),
                            ],
                          ),
                  ),
                )),
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.white, // Android
                  statusBarBrightness: Brightness.dark // IOS.
                  ),
              child: LoginScreen(
                  authenticationAction: AuthenticationAction.signIn,
                  onComplete: () {}),
            ),
          ],
        ));
  }
}

class _Image extends StatelessWidget {
  const _Image();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/bild3.jpg');
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
            'Behalte mit der Bergdinge App deine Ausrüstung im Überblick.',
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
          backgroundColor: Design.colors[1],
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
