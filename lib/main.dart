import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import 'package:plex_user/services/domain/service/app/deeplinking.dart';
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


  await Get.putAsync(() => AppService().init());
  initDeepLinks();
  // await TranslationService.init();
  // final localeCtrl = Get.put(LocaleController());
  // await localeCtrl.init();

  Stripe.publishableKey = "pk_test_51SLeKk6j6LVPNcUmY7DCzoPkKCjUw6ZRJrvPYkBuOyKkPVrh1asHolMVogUcibjlXZa21iWdAWpqOT9PE3dkLu8x00j0btf3Fx";

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness:
    Brightness.dark, // Set your desired status bar color
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(Phoenix(child: Sizer(
      builder: (context, orientation, deviceType) {
        return  Plex();
      },
    )));
  });

}



