import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/services/translations/app_translations.dart';
import 'package:plex_user/services/translations/locale_controller.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart'; // ye file Firebase CLI se generate hoti hai
import 'package:firebase_core/firebase_core.dart';
import 'core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 1) Load translation JSONs
  await TranslationService.init();

  // 2) Put locale controller and apply saved locale (so app starts with right locale)
  final localeCtrl = Get.put(LocaleController());
  await localeCtrl.init();

  // 3) Run app
  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return const Plex();
      },
    ),
  );
}



