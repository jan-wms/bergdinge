import 'dart:math';

import 'package:equipment_app/data/design.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:equipment_app/pages/login/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _innerPageController = PageController(initialPage: 0);
  final _outerPageController = PageController(initialPage: 0);
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  void _nextPage() async {
    if (_innerPageController.page! < 2) {
      _innerPageController.nextPage(
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    } else {
      _outerPageController.jumpToPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeareaPadding = MediaQuery.of(context).padding;
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.black, // Color for Android
            statusBarBrightness: Brightness.light // for IOS.
            ),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _outerPageController,
              children: [
                Flex(
                  direction: (isDesktop) ? Axis.horizontal : Axis.vertical,
                  children: [
                    Expanded(
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
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Design.colors[1],
                              borderRadius: BorderRadius.circular(25.0)
                          ),
                          margin: EdgeInsets.only(
                            top: (isDesktop) ? max(10.0, safeareaPadding.top) : 10.0,
                            right: max(10.0, safeareaPadding.right),
                            bottom: max(10.0, safeareaPadding.bottom),
                            left: (isDesktop)  ? 10.0 : max(10.0, safeareaPadding.left),
                          ),
                          child: Stack(
                          children: [
                            PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _innerPageController,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(30.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(right: 15.0),
                                          child: SvgPicture.asset('assets/icon.svg',
                                              semanticsLabel: 'Bergdinge Icon',
                                              height: 50.0),
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
                                ),
                                Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(right: 15.0),
                                          child: SvgPicture.asset(
                                              'assets/icon.svg',
                                              semanticsLabel: 'Bergdinge Icon',
                                              height: 50.0),
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
                                ),
                                Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(right: 15.0),
                                            child: SvgPicture.asset('assets/icon.svg',
                                                semanticsLabel: 'Bergdinge Icon',
                                                height: 50.0),
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
                                    )),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(55.0),
                              alignment: Alignment.bottomCenter,
                              child: SmoothPageIndicator(
                                  controller: _innerPageController,
                                  count: 3,
                                  effect: const ExpandingDotsEffect(
                                    dotColor: Colors.white,
                                    activeDotColor: Colors.white,
                                  ),
                                  onDotClicked: (index) =>
                                      _innerPageController.animateToPage(index,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut)),
                            ),
                            Container(
                              padding: const EdgeInsets.all(40.0),
                              alignment: Alignment.bottomRight,
                              child: Container(
                                alignment: Alignment.center,
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: const Offset(0, 7),
                                        blurRadius: 10,
                                        color: Design.colors[1].withOpacity(0.23),
                                      )
                                    ]),
                                child: IconButton(
                                  onPressed: () => _nextPage(),
                                  highlightColor: Colors.transparent,
                                  icon: Icon(Icons.chevron_right_rounded,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.7)),
                                ),
                              ),
                            ),
                          ],
                        ),),),
                  ],
                ),
                LoginScreen(
                    authenticationAction: AuthenticationAction.signIn,
                    onComplete: () {}),
              ],
            )));
  }
}
