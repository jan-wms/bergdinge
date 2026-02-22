import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Design {
  static const articleTextStyle = TextStyle(fontSize: 15.0);
  static const articleSubtitleTextStyle = TextStyle(
      fontSize: 17, color: Colors.black54, fontWeight: FontWeight.w600);
  static const articleTitleTextStyle =
      TextStyle(fontSize: 25, fontWeight: FontWeight.w600);

  static const List<Color> section0 = [
    Color.fromRGBO(75, 96, 62, 1.0),
    Color.fromRGBO(27, 92, 34, 1.0),
    Color.fromRGBO(56, 142, 60, 1.0),
    Color.fromRGBO(76, 175, 80, 1.0),
    Color.fromRGBO(129, 199, 132, 1.0),
  ];

  static const List<Color> section1 = [
    Color.fromRGBO(255, 111, 0, 1.0),
    Color.fromRGBO(255, 160, 0, 1.0),
    Color.fromRGBO(255, 193, 7, 1.0),
    Color.fromRGBO(255, 213, 79, 1.0),
  ];

  static const List<Color> section2 = [
    Color.fromRGBO(13, 71, 161, 1.0),
    Color.fromRGBO(30, 136, 229, 1.0),
    Color.fromRGBO(100, 181, 246, 1.0),
  ];

  static const List<Color> section3 = [
    Color.fromRGBO(136, 14, 79, 1.0),
    Color.fromRGBO(216, 27, 96, 1.0),
    Color.fromRGBO(142, 36, 170, 1.0),
  ];

  static Color getSectionColor({required int category, required int index}) {
    late List<Color> colors;
    switch (category) {
      case 1:
        colors = section1;
        break;
      case 2:
        colors = section2;
        break;
      case 3:
        colors = section3;
        break;
      case 0:
        colors = section0;
        break;
      case -1:
      default:
        colors = [
          section0[0],
          section1[0],
          section2[0],
          section3[0],
        ];
        break;
    }
    return colors[index % (colors.length)];
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
      backgroundColor: Design.colors[1],
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
    ),
    colorScheme: ColorScheme.fromSeed(
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
