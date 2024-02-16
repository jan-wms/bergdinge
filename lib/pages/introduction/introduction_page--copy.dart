import 'package:equipment_app/data/design.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../firebase/firebase_auth.dart';
import '../login/login_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _pageController = PageController(initialPage: 0);
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  Future<void> _nextPage() async {
    await _pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.white, // Color for Android
            statusBarBrightness: Brightness.dark // for IOS.
            ),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                              ),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            color: Design.colors[1],
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: SvgPicture.asset('assets/icon.svg', semanticsLabel: 'Bergdinge Icon', height: 50.0),
                                  ),
                                  const Text(
                                    'Bergdinge',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 70.0),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 20,
                        right: 20,
                        child: ElevatedButton(
                            onPressed: () => _nextPage(),
                            child: const Text('Weiter')))
                  ],
                ),
                LoginScreen(
                  authenticationAction: AuthenticationAction.signIn,
                  onComplete: () {},
                ),
              ],
            )));
  }
}
