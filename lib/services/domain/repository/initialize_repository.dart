
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import 'package:plex_user/services/domain/service/api/admin/admin_api.dart';
import 'package:plex_user/services/domain/repository/admin/admin_repository.dart';

Future<void> initializeRepositories() async {
  debugPrint('[REPO INIT] initializeRepositories start');
  try {

    Get.put(AuthRepository());
    // debugPrint('[REPO] AuthRepository registered');

    Get.put(UserRepository());
    // debugPrint('[REPO] UserRepository registered');

    Get.put(MapRepository());
    // debugPrint('[REPO] MapRepository registered');

    Get.put(ShipmentRepository());
    // debugPrint('[REPO] ShipmentRepository registered');

    // Admin API & Repository
    Get.put(AdminApi());
    Get.put(AdminRepository());
    // debugPrint('[REPO] AdminRepository registered');

    // Notification Repository
    Get.put(NotificationRepository());
    // debugPrint('[REPO] NotificationRepository registered');

    debugPrint('[REPO INIT] all repositories registered successfully');
  } catch (e, st) {
    debugPrint('[REPO ERROR] initializeRepositories failed: $e');
    debugPrint(st.toString());
    // Rethrow so the app startup doesn't silently continue in a broken state.
    rethrow;
  }
}
