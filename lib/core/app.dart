// lib/core/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../routes/appRoutes.dart';
import '../services/translations/app_translations.dart';
import '../services/translations/locale_controller.dart';
import 'app_theme.dart';



class Plex extends StatelessWidget {
  const Plex({super.key});
  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        // title: 'app_name'.tr,
        title: 'Plex'.tr,
        theme: AppTheme.light,
        darkTheme:  AppTheme.light,
        translations: TranslationService(), // GetX translations
        locale: localeCtrl.current.value,
        fallbackLocale: TranslationService.defaultFallback,
        supportedLocales: TranslationService.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.userDashBoard,
        getPages: AppRoutes.routes,
        defaultTransition: Transition.cupertino,
      );
    });
  }
}
