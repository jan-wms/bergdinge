import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _pageController = PageController(initialPage: 0);
  ScrollPhysics _scrollPhysics = const PageScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
      physics: _scrollPhysics,
      controller: _pageController,
      children: [
        Container(
          color: Colors.black12,
          child: const Center(
            child: Text('Herzlich willkommen!'),
          ),
        ),
        LoginScreen(
          onWaitingEnd: () => setState(() {
            _scrollPhysics = const PageScrollPhysics();
          }),
          onWaitingStart: () => setState(() {
            _scrollPhysics = const NeverScrollableScrollPhysics();
          }),
        ),
      ],
    ));
  }
}
