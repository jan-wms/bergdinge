import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Design {
  Design._();

  static const articleTextStyle = TextStyle(fontSize: 15.0);
  static const articleSubtitleTextStyle = TextStyle(
      fontSize: 17, color: Colors.black54, fontWeight: FontWeight.w600);
  static const articleTitleTextStyle =
      TextStyle(fontSize: 25, fontWeight: FontWeight.w600);

  static Color getSectionColor(
      {required int colorSection, required int index}) {
    late List<Color> colors;
    switch (colorSection) {
      case 0:
        colors = [
          Color.fromRGBO(75, 96, 62, 1.0),
          Color.fromRGBO(56, 142, 60, 1.0),
          Color.fromRGBO(76, 175, 80, 1.0),
          Color.fromRGBO(27, 92, 34, 1.0),
          Color.fromRGBO(129, 199, 132, 1.0),
        ];
        break;
      case 1:
        colors = [
          Color.fromRGBO(255, 160, 0, 1.0),
          Color.fromRGBO(255, 111, 0, 1.0),
          Color.fromRGBO(255, 193, 7, 1.0),
          Color.fromRGBO(255, 213, 79, 1.0),
        ];
        break;
      case 2:
        colors = [
          Color.fromRGBO(100, 181, 246, 1.0),
        ];
        break;
      case 3:
        colors = [
          Color.fromRGBO(216, 27, 96, 1.0),
        ];
        break;
    }
    return colors[index % colors.length];
  }

  static const Color darkGreen = Color.fromRGBO(36, 49, 25, 1.0);
  static const Color green = Color.fromRGBO(98, 148, 96, 1.0);

  static const pagePadding = EdgeInsets.only(left: 15, right: 15);

  static const double wideScreenBreakpoint = 800.0;

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      backgroundColor: green,
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: green),
      ),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      error: Colors.red,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),
  );

  static final ThemeData lightTheme = _lightTheme.copyWith(
    textTheme: GoogleFonts.rubikTextTheme(_lightTheme.textTheme),
  );
}
