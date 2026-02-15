import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  ThemeData get currentTheme {
    const primary = Color(0xFF1B365D);
    const secondary = Color(0xFFE07A5F);
    const background = Color(0xFFF7F5F2);
    const surface = Color(0xFFFFFFFF);
    const border = Color(0xFFE6E1D9);

    final baseTextTheme = GoogleFonts.workSansTextTheme();
    final displayTextTheme = GoogleFonts.playfairDisplayTextTheme();
    final textTheme = baseTextTheme.copyWith(
      displayLarge: displayTextTheme.displayLarge,
      displayMedium: displayTextTheme.displayMedium,
      displaySmall: displayTextTheme.displaySmall,
      headlineLarge: displayTextTheme.headlineLarge,
      headlineMedium: displayTextTheme.headlineMedium,
      headlineSmall: displayTextTheme.headlineSmall,
      titleLarge: displayTextTheme.titleLarge,
    );

    if (_isDarkMode) {
      final colorScheme = const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: Color(0xFF121212),
        onBackground: Colors.white,
        surface: Color(0xFF1C1B1A),
        onSurface: Colors.white,
      );
      return ThemeData.dark().copyWith(
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1F1F1F),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: background,
      onBackground: primary,
      surface: surface,
      onSurface: primary,
    );

    return ThemeData.light().copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(0),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1ECE6),
        selectedColor: secondary.withOpacity(0.2),
        labelStyle: const TextStyle(color: primary),
        side: const BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
