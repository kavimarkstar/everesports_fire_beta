import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static String lightTheme = 'light';
  static String darkTheme = 'dark';
  static String themeKey = 'app_theme';

  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: mainWhiteColor,
      colorScheme: ColorScheme.light(
        primary: mainColor,
        secondary: mainColor,
        surface: Colors.white,
        background: Color(0xFFF5F8FA),
        error: Color(0xFFE0245E),
      ),
      scaffoldBackgroundColor: secondWhiteColor,
      elevatedButtonTheme: ElevatedButtonThemeData(),
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: mainBlackColor),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.white,
        clipBehavior: Clip.hardEdge,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.black),
        displayMedium: TextStyle(color: Colors.black),
        displaySmall: TextStyle(color: Colors.black),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black87),
        labelLarge: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.black54),
      ),
      iconTheme: IconThemeData(color: Color(0xFF657786)),
      dividerTheme: DividerThemeData(
        color: Color(0xFFE1E8ED),
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: mainColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: mainColor,
        unselectedItemColor: Color(0xFF657786),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: mainBlackColor,
      colorScheme: ColorScheme.dark(
        primary: mainColor,
        secondary: mainColor,
        surface: Color(0xFF15202B),
        background: Color(0xFF15202B),
        error: Color(0xFFE0245E),
      ),
      scaffoldBackgroundColor: mainBlackColor,
      appBarTheme: AppBarTheme(
        color: mainBlackColor,
        elevation: 0,
        iconTheme: IconThemeData(color: mainWhiteColor),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: secondBlackColor,
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: secondBlackColor,
        clipBehavior: Clip.hardEdge,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white70),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white54),
      ),
      iconTheme: IconThemeData(color: Color(0xFF8899A6)),
      dividerTheme: DividerThemeData(
        color: Color(0xFF38444D),
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: mainColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: mainBlackColor,
        selectedItemColor: mainColor,
        unselectedItemColor: Color(0xFF8899A6),
      ),
    );
  }

  static Future<void> setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, themeName);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themeKey) ?? lightTheme;
  }
}
