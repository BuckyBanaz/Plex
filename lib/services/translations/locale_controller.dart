// lib/services/locale_controller.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'app_translations.dart';

class LocaleController extends GetxService {
  static const _languageKey = 'app_language';

  /// Reactive current locale
  final Rx<Locale> current = TranslationService.defaultLocale.obs;

  // init after Get.put(LocaleController())
  Future<LocaleController> init() async {
    await applySavedLocale();
    return this;
  }

  // lib/services/locale_controller.dart
  Future<void> applySavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    if (saved != null && saved.isNotEmpty) {
      final loc = TranslationService.localeFromCode(saved);
      current.value = loc;
      Get.updateLocale(loc);
    } else {
      current.value = TranslationService.defaultLocale; // Arabic by default
      Get.updateLocale(TranslationService.defaultLocale);
    }
  }


  /// Save language code (use 'en_US' or 'ar_SA')
  Future<void> saveAndChange(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
    final loc = TranslationService.localeFromCode(code);
    current.value = loc;
    Get.updateLocale(loc);
  }

  /// Human-readable label for UI
  static String codeToLabel(String code) {
    switch (code) {
      case 'ar_SA':
        return 'العربية';
      case 'en_US':
      default:
        return 'English';
    }
  }

  /// Convert Locale -> code string (same format used in TranslationService)
  static String localeToCode(Locale loc) {
    final code = '${loc.languageCode}_${loc.countryCode}';
    if (TranslationService.supportedCodes.contains(code)) return code;
    return 'en_US';
  }

  /// Whether current locale is RTL
  bool get isCurrentRTL {
    return Bidi.isRtlLanguage(current.value.languageCode);
  }
}