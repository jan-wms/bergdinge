import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../firebase/firebase_auth.dart';
import '../login/login_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  //TODO initialPage: 0
  final _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness:
        Brightness.dark // for IOS.
    ),
    child: Scaffold(
      backgroundColor: Colors.white,
        body: PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: [
        Container(
          color: Colors.black12,
          child: Stack(
            children: [
              const Center(
                child: Text('Herzlich willkommen!'),
              ),
              Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton(
                      onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut),
                      child: const Text('Weiter')))
            ],
          ),
        ),
        LoginScreen(
          authenticationAction: AuthenticationAction.signIn,
          onComplete: () {},
        ),
      ],
    )));
  }
}
