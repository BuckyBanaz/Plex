// lib/services/app_translations.dart
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TranslationService extends Translations {
  /// Use consistent codes with underscore. These are also the filenames:
  /// assets/translations/en_US.json
  /// assets/translations/ar_SA.json
  static const List<String> supportedCodes = ['en_US', 'ar_SA'];

  // Defaults
  // Defaults: Change here
  static const Locale defaultLocale = Locale('ar', 'SA');   // Saudi Arabic as default
  static const Locale defaultFallback = Locale('ar', 'SA'); // Fallback also Arabic


  static late Map<String, Map<String, String>> _translations;

  /// Convert code -> Locale (same code format as supportedCodes)
  static Locale localeFromCode(String code) {
    switch (code) {
      case 'ar_SA':
        return const Locale('ar', 'SA');
      case 'en_US':
      default:
        return const Locale('en', 'US');
    }
  }

  /// Init: load JSON translation files into memory.
  static Future<void> init() async {
    _translations = await _loadAll();
  }

  static Future<Map<String, Map<String, String>>> _loadAll() async {
    final Map<String, Map<String, String>> out = {};
    for (final code in supportedCodes) {
      try {
        // filenames must match codes above (underscore)
        final jsonStr = await rootBundle.loadString('assets/translations/$code.json');
        final Map<String, dynamic> raw = json.decode(jsonStr);
        out[code] = raw.map((k, v) => MapEntry(k, v.toString()));
      } catch (e) {
        // Log or handle missing file gracefully
        // print('Translation load failed for $code: $e');
      }
    }
    return out;
  }

  /// Translations required by GetX Translations
  @override
  Map<String, Map<String, String>> get keys {
    // Ensure it's initialized (should be called before runApp)
    return _translations;
  }

  /// Expose supported locales for MaterialApp
  static List<Locale> get supportedLocales => supportedCodes.map(localeFromCode).toList();

  /// Convenience: list of GetX Locale objects (if needed)
  static List<Locale> get getxLocales => supportedLocales;
}