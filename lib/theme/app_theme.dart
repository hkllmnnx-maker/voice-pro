import 'package:flutter/material.dart';

class AppColors {
  // Primary dark theme colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceMedium = Color(0xFF1A2332);
  static const Color surfaceLight = Color(0xFF243044);
  static const Color cardBg = Color(0xFF151E2E);

  // Accent colors
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDark = Color(0xFF00B8D4);
  static const Color cyanLight = Color(0xFF80F0FF);
  static const Color teal = Color(0xFF00BFA5);
  static const Color purple = Color(0xFF7C4DFF);
  static const Color purpleLight = Color(0xFFB388FF);
  static const Color redAccent = Color(0xFFFF1744);
  static const Color amber = Color(0xFFFFAB00);
  static const Color green = Color(0xFF00E676);

  // Text colors
  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color textTertiary = Color(0xFF5F6368);

  // Gradients
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [cyan, cyanDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient recordGradient = LinearGradient(
    colors: [redAccent, Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfaceDark, surfaceMedium],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.cyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.purple,
        surface: AppColors.surfaceDark,
        error: AppColors.redAccent,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.cyan),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.background,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.cyan,
        inactiveTrackColor: AppColors.surfaceLight,
        thumbColor: AppColors.cyan,
        overlayColor: AppColors.cyan.withValues(alpha: 0.2),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cyan;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.cyan.withValues(alpha: 0.3);
          }
          return AppColors.surfaceLight;
        }),
      ),
    );
  }
}
