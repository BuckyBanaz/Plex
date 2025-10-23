import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFFA726); // Orange/Yellow button

  static const MaterialColor primarySwatch = MaterialColor(
    0xFFFFA726,
    <int, Color>{
      50: Color(0xFFFFF3E0),  // Lightest
      100: Color(0xFFFFE0B2),
      200: Color(0xFFFFCC80),
      300: Color(0xFFFFB74D),
      400: Color(0xFFFFA726), // Main
      500: Color(0xFFFB8C00),
      600: Color(0xFFF57C00),
      700: Color(0xFFEF6C00),
      800: Color(0xFFE65100),
      900: Color(0xFFBF360C), // Darkest
    },
  );
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const Color secondary = Color(0xFF1E2A47); // Dark navy bg
  static const Color textColor = Colors.white;
  static const Color textGrey = Color(0XFF77869E);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFFB0BEC5); // greyish
  static const Color cardBg = Color(0xFF24314F); // login card bg
  static const Color cardColor = Color(0xFFFDF1DE); // login card bg
}
