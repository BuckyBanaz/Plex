// lib/core/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../routes/appRoutes.dart';
import '../services/translations/app_translations.dart';
import '../services/translations/locale_controller.dart';
import 'app_theme.dart';


class TempContext {
  static late BuildContext context;
}


class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // checkConnection();
      // checkInitialMessage();
    }
  }
}

class Plex extends StatelessWidget {
   Plex({super.key});
  final AppLifecycleObserver lifecycleObserver = AppLifecycleObserver();

  @override
  Widget build(BuildContext context) {

    final localeCtrl = Get.find<LocaleController>();
    WidgetsBinding.instance.addObserver(lifecycleObserver);
    TempContext.context = context;

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
        initialRoute: AppRoutes.login,
        getPages: AppRoutes.routes,
        defaultTransition: Transition.cupertino,
      );
    });
  }
}
