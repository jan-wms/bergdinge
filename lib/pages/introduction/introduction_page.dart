import 'package:equipment_app/data/design.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:equipment_app/pages/login/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

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
    final safeareaPadding = MediaQuery.of(context).padding;
    bool isDesktop = MediaQuery.of(context).size.width > 800;

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
                  padding: Design.pagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Dein Abenteuer beginnt hier.',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Behalte mit Bergdinge deine Ausrüstung im Überblick.',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                            foregroundColor: Colors.white,
                            backgroundColor: Design.colors[1],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        onPressed: () => _outerPageController.jumpToPage(1),
                        child: Container(
                          alignment: Alignment.center,
                          height: 30,
                          width: 200,
                          child: const Text(
                            'Entdecken',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ),
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
