import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/design.dart';

class ErrorPage extends StatelessWidget {
  final GoException? exception;
  const ErrorPage({super.key, required this.exception});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.black, // Android
          statusBarBrightness: Brightness.light // IOS.
          ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: SvgPicture.asset('assets/icon.svg',
                          semanticsLabel: 'Bergdinge Icon',
                          height: 20.0,
                          colorFilter: ColorFilter.mode(
                              Design.darkGreen, BlendMode.srcIn)),
                    ),
                    Text(
                      'Bergdinge',
                      style: TextStyle(
                          color: Design.darkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Ein Fehler ist aufgetreten. ${exception?.message}'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17.0,
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Design.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  onPressed: () => context.go('/'),
                  child: Text('Zur Startseite'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

