import 'package:flutter/material.dart';

class Design {
  static const List<Color> sectionColor = [
    Colors.blueAccent,
    Colors.lightBlueAccent,
    Colors.blueGrey,
    Colors.lightBlue,
    Colors.blue,
  ];
  static const List<Color> textColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  static const double breakpoint1 = 600.0;
  static const double breakpoint2 = 1000.0;

  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );
}