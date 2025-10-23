// lib/core/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../constant/app_colors.dart';

class AppTheme {
  /// Light theme
  static ThemeData get light {
    final loc = Get.locale ?? const Locale('en', 'US');
    return themeFor(loc);
  }

  /// Generate theme based on locale
  static ThemeData themeFor(Locale locale) {
    final isArabic = locale.languageCode.toLowerCase().startsWith('ar');

    // Font selection
    final baseTextTheme = isArabic
        ? GoogleFonts.tajawalTextTheme()
        : GoogleFonts.interTextTheme();

    final textTheme = baseTextTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );


    final inputDecoration = InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 3.5),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    );

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // Input fields
      inputDecorationTheme: inputDecoration,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withOpacity(0.3),
        selectionHandleColor: AppColors.primary,
      ),
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: (isArabic
            ? GoogleFonts.tajawal(
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        )
            : GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ))
            .copyWith(color: AppColors.textPrimary),
      ),

      // Dropdown Menu (unified style)
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.white),
        inputDecorationTheme: inputDecoration.copyWith(
          fillColor: AppColors.primary,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.primary),
          padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// Current theme based on Get.locale
  static ThemeData get currentTheme {
    final loc = Get.locale ?? const Locale('en', 'US');
    return themeFor(loc);
  }
}
