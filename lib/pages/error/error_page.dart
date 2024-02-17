import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../data/design.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.black, // Android
          statusBarBrightness: Brightness.light // IOS.
          ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            direction: (isDesktop) ? Axis.horizontal : Axis.vertical,
            children: [
              Container(
                width: (isDesktop)
                    ? MediaQuery.of(context).size.width * 0.5
                    : null,
                padding: const EdgeInsets.all(30.0),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SvgPicture.asset('assets/icon.svg',
                            semanticsLabel: 'Bergdinge Icon',
                            height: 50.0,
                            colorFilter: ColorFilter.mode(
                                Design.colors[0], BlendMode.srcIn)),
                      ),
                      Text(
                        'Bergdinge',
                        style: TextStyle(
                            color: Design.colors[0],
                            fontWeight: FontWeight.bold,
                            fontSize: 70.0),
                      ),
                    ],
                  ),
                ),
              ),
              if (isDesktop)
                SizedBox(
                  width: (isDesktop)
                      ? MediaQuery.of(context).size.width * 0.5
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Lottie.asset('assets/error.json')),
                      const _Button(),
                    ],
                  ),
                ),
              if (!isDesktop)
                Flexible(child: Lottie.asset('assets/error.json')),
              if (!isDesktop) const _Button(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: max(50.0, MediaQuery.of(context).size.width * 0.1)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
            ),
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
            foregroundColor: Colors.white,
            backgroundColor: Design.colors[1],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0))),
        onPressed: () => context.go('/'),
        child: Container(
          alignment: Alignment.center,
          height: 50,
          width: 210,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Zur Startseite'),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.east_rounded),
              )
            ],
          ),
        ),
      ),
    );
  }
}
