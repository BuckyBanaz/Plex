import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../services/domain/service/app/app_service_imports.dart';

class EnsureAuthMiddleware extends GetMiddleware {
  EnsureAuthMiddleware();

  @override
  RouteSettings? redirect(String? route) {
    var db = Get.find<DatabaseService>();

    try {
      var isAccessTokenAvailable = db.accessToken != null;

      if (isAccessTokenAvailable) {
        var userType = db.userType;

        if (userType == 'individual') {
          // --- USER LOGIC ---
          var user = db.user;
          if (user == null) {
            return const RouteSettings(name: AppRoutes.login);
          }

          if (user.name != null) {
            bool isLocationScreenShown = db.isLocationScreenShown ?? false;
            if (isLocationScreenShown) {

              // *** CHANGE 1: Redirect to dashboard ***
              // User is fully logged in and setup. Go to dashboard.
              return const RouteSettings(name: AppRoutes.userDashBoard);

            } else {
              return const RouteSettings(name: AppRoutes.location);
            }
          } else {
            return const RouteSettings(name: AppRoutes.choose); // Profile not complete
          }

        } else if (userType == 'driver') {
          // --- DRIVER LOGIC ---
          var driver = db.driver;
          if (driver == null) {
            return const RouteSettings(name: AppRoutes.login);
          }

          if (driver.name != null) {
            bool isLocationScreenShown = db.isLocationScreenShown ?? false;
            if (isLocationScreenShown) {

              // *** CHANGE 1: Redirect to dashboard ***
              // Driver is fully logged in and setup. Go to dashboard.
              return const RouteSettings(name: AppRoutes.driverDashBoard);

            } else {
              return const RouteSettings(name: AppRoutes.location);
            }
          } else {
            return const RouteSettings(name: AppRoutes.choose); // Profile not complete
          }

        } else {
          // User type is unknown or null, force login
          return const RouteSettings(name: AppRoutes.login);
        }
      } else {
        // *** CHANGE 2 (Recommended) ***
        // Access token is not available. Let the splash screen load normally.
        // Your splash screen can then redirect to login.
        // This stops the app from jarringly skipping splash.
        return null;
      }
    } catch (e) {
      // *** CHANGE 2 (Recommended) ***
      // On error, also let the splash screen load.
      return null;
    }
  }
}