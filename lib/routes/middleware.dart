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
          return _handleUserRedirect(db);
          
        } else if (userType == 'driver') {
          // --- DRIVER LOGIC ---
          return _handleDriverRedirect(db);
          
        } else {
          // User type is unknown or null, force login
          return const RouteSettings(name: AppRoutes.login);
        }
      } else {
        // Access token not available - let splash screen load
        return null;
      }
    } catch (e) {
      debugPrint('Middleware error: $e');
      return null;
    }
  }

  /// Handle user (individual) redirect logic
  RouteSettings? _handleUserRedirect(DatabaseService db) {
    var user = db.user;
    if (user == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (user.name.isNotEmpty) {
      bool isLocationScreenShown = db.isLocationScreenShown ?? false;
      if (isLocationScreenShown) {
        // User is fully logged in and setup -> Dashboard
        return const RouteSettings(name: AppRoutes.userDashBoard);
      } else {
        return const RouteSettings(name: AppRoutes.location);
      }
    } else {
      // Profile not complete
      return const RouteSettings(name: AppRoutes.choose);
    }
  }

  /// Handle driver redirect logic with KYC status
  RouteSettings? _handleDriverRedirect(DatabaseService db) {
    var driver = db.driver;
    if (driver == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Check if driver name is set (basic profile complete)
    if (driver.name.isEmpty) {
      return const RouteSettings(name: AppRoutes.choose);
    }

    // ONLY rely on backend kycStatus from driver model
    String? kycStatus = driver.kycStatus;
    debugPrint('Middleware - Driver kycStatus: $kycStatus');
    
    // Check KYC status
    if (kycStatus == null || kycStatus.isEmpty || kycStatus == 'not_submitted') {
      // KYC not submitted -> go to KYC screen
      return const RouteSettings(name: AppRoutes.kyc);
    } else if (kycStatus == 'verified') {
      // Driver is fully verified -> go to dashboard
      bool isLocationScreenShown = db.isLocationScreenShown ?? false;
      if (isLocationScreenShown) {
        return const RouteSettings(name: AppRoutes.driverDashBoard);
      } else {
        return const RouteSettings(name: AppRoutes.location);
      }
    } else {
      // pending, awaiting_approval, rejected -> approval screen
      return const RouteSettings(name: AppRoutes.approvel);
    }
  }
}

/// Middleware to prevent logged-in users from accessing login/signup screens
class EnsureNotAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    var db = Get.find<DatabaseService>();
    
    try {
      var isAccessTokenAvailable = db.accessToken != null;
      
      if (isAccessTokenAvailable) {
        var userType = db.userType;
        
        // User is already logged in, redirect appropriately
        if (userType == 'individual') {
          var user = db.user;
          if (user != null && user.name.isNotEmpty) {
            bool isLocationScreenShown = db.isLocationScreenShown ?? false;
            if (isLocationScreenShown) {
              return const RouteSettings(name: AppRoutes.userDashBoard);
            }
            return const RouteSettings(name: AppRoutes.location);
          }
          return const RouteSettings(name: AppRoutes.choose);
          
        } else if (userType == 'driver') {
          var driver = db.driver;
          if (driver == null) {
            return null; // Allow login
          }
          
          // Check if driver profile is complete
          if (driver.name.isEmpty) {
            return const RouteSettings(name: AppRoutes.choose);
          }
          
          // ONLY rely on backend kycStatus
          String? kycStatus = driver.kycStatus;
          
          // KYC not started
          if (kycStatus == null || kycStatus.isEmpty || kycStatus == 'not_submitted') {
            return const RouteSettings(name: AppRoutes.kyc);
          }
          
          // Check KYC verification status
          if (kycStatus == 'verified') {
            bool isLocationScreenShown = db.isLocationScreenShown ?? false;
            if (isLocationScreenShown) {
              return const RouteSettings(name: AppRoutes.driverDashBoard);
            }
            return const RouteSettings(name: AppRoutes.location);
          } else {
            // pending, awaiting_approval, rejected -> approval screen
            return const RouteSettings(name: AppRoutes.approvel);
          }
        }
      }
      
      // Not logged in, allow access to auth screens
      return null;
    } catch (e) {
      debugPrint('EnsureNotAuthMiddleware error: $e');
      return null;
    }
  }
}
