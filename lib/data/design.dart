import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const List<Color> colors = [
    Color.fromRGBO(36, 49, 25, 1.0),
    Color.fromRGBO(98, 148, 96, 1.0),
    Color.fromRGBO(150, 190, 140, 1.0),
    Color.fromRGBO(172, 236, 161, 1.0),
    Color.fromRGBO(201, 242, 199, 1.0),
  ];

  static const pagePadding = EdgeInsets.only(left: 15, right: 15);

  static const double breakpoint1 = 600.0;
  static const double breakpoint2 = 1000.0;

  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Design.colors[1],
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    )
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );
}