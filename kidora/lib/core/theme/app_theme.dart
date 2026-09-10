import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF9F1C); // Orange chaleureux
  static const secondary = Color(0xFF2EC4B6); // Turquoise ludique
  static const accent = Color(0xFFE71D36); // Rouge vif pour alertes/badges
  static const background = Color(0xFFFDFFFC); // Fond légèrement cassé
  static const text = Color(0xFF011627); // Bleu marine très foncé (lisibilité)
  
  // Matières
  static const math = Color(0xFFFF5964);
  static const french = Color(0xFF35A7FF);
  static const science = Color(0xFF38B000);
  static const logic = Color(0xFF7000FF);
  
  static const cardBg = Color(0xFFF1FAEE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
        bodyLarge: TextStyle(fontSize: 18, color: AppColors.text, height: 1.5),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.text),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
        ),
      ),
    );
  }
}
