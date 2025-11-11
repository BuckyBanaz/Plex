part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class UserRepository {
  final UserApi userApi = Get.find<UserApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();
  final LocaleController localeController = Get.find<LocaleController>();
  final DeviceInfoService deviceInfoService = Get.find<DeviceInfoService>();

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

  Future<String> confirmPaymentStripe({
    required String paymentIntentId,
    required String paymentMethod,
  }) async {
    try {
      final Map<String, dynamic> data = await userApi.confirmStripePayment(
        paymentIntentId: paymentIntentId,
        paymentMethod: paymentMethod,
      );

      if (data.containsKey('status')) {
        return data['status'].toString();
      }

      if (data.containsKey('client_secret')) {
        return data['client_secret'].toString();
      }

      // fallback: return full JSON if neither key is present
      return jsonEncode(data);
    } catch (e) {
      // You may want to convert the error to your app-specific exception
      rethrow;
    }
  }
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final response = await userApi.getAddress(langKey: langKey);

      debugPrint("User address get successfully via repository.");

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((e) => AddressModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error user Address: $e");
      return [];
    }
  }

  Future<void> addUserAddress({
    required String address,
    required String addressAs,
    required String landmark,
    required String locality,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    try {
      final apiKey = databaseService.apiKey.toString();

      await userApi.addAddress(
        address: address,
        addressAs: addressAs,
        landmark: landmark,
        locality: locality,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        langKey: langKey,
      );

      debugPrint("User address added successfully via repository.");
      showToast(message: "Address added successfully");
    } catch (e) {
      debugPrint("Error user Address: $e");
      showToast(message: "Failed to add Address");
    }
  }
  /// Delete address by id. Returns true when deletion succeeded.
  Future<bool> deleteUserAddress({ required int id }) async {
    try {
      final response = await userApi.deleteAddress(id: id, langKey: langKey);

      debugPrint("User address delete response via repository: $response");

      // Depending on your backend, you might get { success: true } or { message: '...' }
      if (response['success'] == true || response['status'] == 'success' || (response['message'] != null)) {
        showToast(message: "Address deleted successfully");
        return true;
      }

      showToast(message: "Failed to delete address");
      return false;
    } catch (e) {
      debugPrint("Error deleting user Address: $e");
      showToast(message: "Failed to delete address");
      return false;
    }
  }

  Future<void> updateStatus(bool isOnline) async {
    try {
      final userType = databaseService.userType; // 'individual' or 'driver'

      // Run only for driver
      if (userType != 'driver') {
        debugPrint("⚠️ updateStatus skipped — user is not a driver ($userType)");
        return;
      }

      final driver = databaseService.driver;
      final driverId = driver?.id?.toString();

      if (driverId == null) {
        debugPrint("❌ No driverId found for driver");
        showToast(message: "Failed to update status (no driverId)");
        return;
      }

      // Call API
      final response = await userApi.updateStatus(
        userId: driverId,
        isOnline: isOnline,
      );

      if (response['success'] == true || response['message'] != null) {
        debugPrint("✅ Driver online status updated successfully");

      } else {
        debugPrint("⚠️ Failed to update driver status: $response");
        showToast(message: "Failed to update driver status");
      }
    } catch (e) {
      debugPrint("❌ Error updating driver status: $e");
      showToast(message: "Error updating driver status");
    }
  }



  Future<void> updateFcmToken() async {
    try {
      final userType = databaseService.userType; // 'individual' or 'driver'
      final user = databaseService.user;
      final driver = databaseService.driver;
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // Determine userId depending on user type
      String? userId;
      if (userType == 'individual') {
        userId = user?.id?.toString();
      } else if (userType == 'driver') {
        userId = driver?.id?.toString();
      }

      if (userId == null) {
        debugPrint("❌ No userId found for $userType");
        showToast(message: "Failed to update FCM token (no userId)");
        return;
      }

      // Call API
      final response = await userApi.updateFcm(
        userId: userId,
        fcmToken: deviceInfo.firebaseToken,
      );

      if (response['success'] == true || response['message'] != null) {
        debugPrint("✅ FCM token updated successfully for $userType");
      } else {
        debugPrint("⚠️ Failed to update FCM token: $response");
      }
    } catch (e) {
      debugPrint("❌ Error updating FCM token: $e");
    }
  }


}