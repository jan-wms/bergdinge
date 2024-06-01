import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Design {
  /*static const List<Color> sectionColors = [
    Color.fromRGBO(75, 96, 62, 1.0),
    Color.fromRGBO(98, 148, 96, 1.0),
    Color.fromRGBO(150, 190, 140, 1.0),
    Color.fromRGBO(137, 166, 137, 1.0),
    Color.fromRGBO(201, 242, 199, 1.0),
    Color.fromRGBO(239, 255, 224, 1.0),
  ];*/

  static const List<Color> sectionColors = [
    Color.fromRGBO(75, 96, 62, 1.0),
    Color.fromRGBO(225, 116, 38, 1.0),
    Color.fromRGBO(38, 103, 225, 1.0),
    Color.fromRGBO(38, 225, 153, 1.0),
  ];

  static Color getSectionColor (int i) {
    return sectionColors[i % (sectionColors.length)];
  }

  static const List<Color> disabledSectionColors = [
    Color.fromRGBO(173, 206, 148, 1.0),
    Color.fromRGBO(213, 160, 122, 1.0),
    Color.fromRGBO(127, 160, 218, 1.0),
    Color.fromRGBO(146, 220, 191, 1.0),
  ];

  static Color getDisabledSectionColor (int i) {
    return disabledSectionColors[i % (disabledSectionColors.length)];
  }

  static const List<Color> colors = [
    Color.fromRGBO(36, 49, 25, 1.0),
    Color.fromRGBO(98, 148, 96, 1.0),
    Color.fromRGBO(150, 190, 140, 1.0),
    Color.fromRGBO(172, 236, 161, 1.0),
    Color.fromRGBO(201, 242, 199, 1.0),
    Color.fromRGBO(239, 255, 224, 1.0),
    Color.fromRGBO(189, 166, 57, 1.0),
    Color.fromRGBO(252, 253, 247, 1.0),
  ];

  static const pagePadding = EdgeInsets.only(left: 15, right: 15);

  static const double breakpoint1 = 800.0;

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      color: Design.colors[1],
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Design.colors[1],
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: colors.elementAt(2)),
      ),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    ), colorScheme: ColorScheme.fromSeed(
      seedColor: colors.elementAt(2),
      error: Colors.red,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),
  );

  ThemeData get lightTheme => _lightTheme.copyWith(
  textTheme: GoogleFonts.rubikTextTheme(_lightTheme.textTheme),
  );
}
