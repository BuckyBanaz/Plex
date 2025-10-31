part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class UserRepository {
  final UserApi userApi = Get.find<UserApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();
  final LocaleController localeController = Get.find<LocaleController>();

  // int get langKey {
  //   // Map locale to langKey required by API
  //   switch (localeController.current.value.toString()) {
  //     case 'en_US':
  //       return 1; // English
  //     case 'ar_SA':
  //       return 2; // Arabic/Saudi
  //     default:
  //       return 1;
  //   }
  // }
  int langKey = 1;

  Future<void> updateUserLocation(Position position) async {
    try {

      final apiKey = databaseService.apiKey.toString();

      await userApi.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        // Use position.timestamp if available, otherwise use current time
        recordedAt: position.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        langKey: langKey,
        apiKey: apiKey,
      );

      debugPrint("User location updated successfully via repository.");

    } catch (e) {
      debugPrint("Error updating user location: $e");
      // Optionally re-throw or show a toast
      showToast(message: "Failed to update location");
    }
  }



  /// amount is in smallest currency unit (e.g., paise for INR, cents for USD)
  Future<String> createPaymentIntent({ required int amount, String currency = 'inr', String? orderId }) async {
    final data = await userApi.createPaymentIntent(amount: amount, currency: currency, orderId: orderId);
    // expect { clientSecret: "...", paymentIntentId: "pi_..." }
    return data['clientSecret'] as String;
  }
}