part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class AuthRepository {
  final AuthApi authApi = Get.find<AuthApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();
  final DeviceInfoService deviceInfoService = Get.find<DeviceInfoService>();
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
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await authApi.login(
        email: email,
        password: password,
        langKey: langKey,
      );

      // token
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await databaseService.putAccessToken(token);
        print("Access token saved");
      } else {
        print("Auth token not present in login response");
      }


      final apiKeyFromResp = (data['key'] ?? data['key'] ?? data['key']) as String?;
      if (apiKeyFromResp != null && apiKeyFromResp.isNotEmpty) {
        await databaseService.putApiKey(apiKeyFromResp);
        print("API key saved: ${apiKeyFromResp.substring(0, 6)}...");
      } else {
        print("API key not present in top-level response. Checking user object...");
        final userMap = data['user'] as Map<String, dynamic>?;
        final apiKeyFromUser = (userMap?['key'] ?? userMap?['key']) as String?;
        if (apiKeyFromUser != null && apiKeyFromUser.isNotEmpty) {
          await databaseService.putApiKey(apiKeyFromUser);
          print("API key saved from user object");
        } else {
          print("API key not found anywhere in response. Full response: $data");
        }
      }

      // user
      final userJson = data['user'];
      if (userJson == null) {
        throw Exception("User data not found in login response");
      }
      final userType = (userJson['userType'] as String? ?? 'individual').toLowerCase();

      await databaseService.putUserType(userType);

      if (userType == 'driver') {
        final driver = DriverUserModel.fromJson(userJson);
        await databaseService.putDriver(driver);
        print("Driver data loaded");
        return driver;
      } else {
        final user = UserModel.fromJson(userJson);
        await databaseService.putUser(user);
        print("User data loaded");
        return user;
      }
    } on DioError catch (dioError) {
      final respData = dioError.response?.data;
      final msg = respData is Map
          ? (respData['message'] ?? respData['error'])
          : dioError.message;
      throw Exception("Login failed: ${msg ?? dioError.message}");
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }



  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // get device id
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // call API
      final response = await authApi.register(
        name: name,
        email: email,
        password: password,
        deviceId: deviceInfo.deviceId,
        phone: phone,
        langKey: langKey,
        otpType: 'email',
        fcmToken: deviceInfo.firebaseToken,
      );

      final statusCode =
          response['statusCode'] ?? 200; // fallback 200 if not provided
      if (statusCode != 200 && statusCode != 201) {
        final error = response['error'] ?? 'Registration failed';
        throw Exception(error.toString());
      }

      // store api_key if available
      if (response.containsKey('key')) {
        await databaseService.putApiKey(response['key']);
      }

      // return success message
      return response['message']?.toString() ?? 'Registered successfully';
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Registration failed';
      debugPrint('register() failed: $msg');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    required String licenseNo,
  }) async {
    try {
      // get device id
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      // call API
      final response = await authApi.registerDriver(
        name: name,
        email: email,
        phone: phone,
        password: password,
        langKey: langKey,
        vehicleType: vehicleType,
        licenseNo:licenseNo,

        deviceId: deviceInfo.deviceId,
        fcmToken: deviceInfo.firebaseToken,
      );

      // check status code
      final status = response.statusCode ?? 0;
      if (status != 200 && status != 201) {
        final serverMsg = (response.data is Map)
            ? (response.data['error'] ??
                  response.data['message'] ??
                  'Unknown error')
            : 'Registration failed: $status';
        throw Exception(serverMsg);
      }

      // convert to Map<String, dynamic>
      final data = (response.data is Map<String, dynamic>)
          ? Map<String, dynamic>.from(response.data)
          : {'message': response.data?.toString() ?? 'Success'};

      // store api_key if present
      if (data.containsKey('api_key')) {
        await databaseService.putApiKey(data['api_key']);
      }

      return data;
    } catch (e, stackTrace) {
      debugPrint("Error during driver registration: $e");
      debugPrint("StackTrace: $stackTrace");
      throw Exception("Driver registration failed. Please try again later.");
    }
  }

  Future<String> registerCorporate({
    required CorporateRegisterModel model,
  }) async {
    try {
      final data = await authApi.registerCorporate(body: model.toJson());

      if (data.containsKey('error')) {
        throw Exception(data['error'].toString());
      }

      if (data.containsKey('message')) {
        return data['message'].toString();
      }

      // fallback in case response shape is unexpected
      return data.values.join(' ');
    } catch (e, stackTrace) {
      debugPrint('registerCorporate() failed: $e');
      debugPrint(stackTrace.toString());
      throw Exception('Corporate registration failed. Please try again later.');
    }
  }

  Future<bool> verifyOtp({
    required String keyType,
    required String keyValue,
    required String otp,
  }) async {
    try {
      final apiKey = databaseService.apiKey.toString();
      final response = await authApi.verifyOtp(
        keyType: keyType,
        keyValue: keyValue,
        otp: otp,
        langKey: langKey,
        apiKey: apiKey,
      );

      if (response.statusCode == 200) return true;
      if (response.statusCode == 400 || response.statusCode == 401)
        return false;

      final msg = (response.data is Map)
          ? (response.data['message'] ?? response.data['error'])
          : null;

      throw Exception(msg?.toString() ?? 'OTP verification failed');
    } catch (e, stackTrace) {
      debugPrint('verifyOtp() failed: $e');
      debugPrint(stackTrace.toString());
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  /// Forgot Password Logic
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      // 🔹 API call
      final  response = await authApi.forgotPassword(
        email: email,
        langKey: langKey,
      );

      // 🔹 Success handling
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          "success": true,
          "message": data["message"] ?? "Password reset link sent successfully.",
          "data": data,
        };
      } else {
        // 🔹 API returned non-200
        return {
          "success": false,
          "message": response.data["message"] ?? "Something went wrong.",
        };
      }
    } catch (e) {
      // 🔹 Exception handling
      return {
        "success": false,
        "message": "Failed to send reset link. Please try again later.",
        "error": e.toString(),
      };
    }
  }


  Future<String> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await authApi.resetPassword(
        password: newPassword,
        conPassword: confirmPassword,
        token: token,
      );

      final status = response.statusCode ?? 0;

      // Common success codes: 200 or 201
      if (status == 200 || status == 201) {
        // Try to parse message from response
        final data = response.data;
        if (data is Map && (data['message'] != null || data['success'] != null)) {
          // prefer message key, fallback to success
          final message = data['message']?.toString() ?? data['success']?.toString() ?? 'Password reset successful';
          return message;
        }

        // fallback if shape unexpected
        return 'Password reset successful';
      }

      // Non-success status: try to extract meaningful error
      final serverMessage = (response.data is Map)
          ? (response.data['message'] ?? response.data['error'] ?? response.data.toString())
          : response.data?.toString();

      throw Exception(serverMessage ?? 'Password reset failed (status: $status)');
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      final msg = (serverData is Map)
          ? (serverData['message'] ?? serverData['error'] ?? dioError.message)
          : dioError.message;
      debugPrint('resetPassword() DioError: $msg');
      throw Exception(msg ?? 'Network error while resetting password');
    } catch (e, st) {
      debugPrint('resetPassword() failed: $e\n$st');
      throw Exception(e.toString());
    }
  }

  Future<bool> resendOtp({
    required String keyType,
    required String keyValue,
  }) async {
    try {
      // final apiKey = databaseService.apiKey.toString();
      final response = await authApi.resendOtp(
        keyType: keyType,
        keyValue: keyValue,

        langKey: langKey,
      );

      if (response.statusCode == 200) return true;
      if (response.statusCode == 400 || response.statusCode == 401) return false;

      final msg = (response.data is Map)
          ? (response.data['message'] ?? response.data['error'])
          : null;

      throw Exception(msg?.toString() ?? 'Resend OTP failed');
    } catch (e, stackTrace) {
      debugPrint('resendOtp() failed: $e');
      debugPrint(stackTrace.toString());
      throw Exception('Failed to resend OTP. Please try again.');
    }
  }

  Future<RefreshStatus> refreshToken() async {
    try {

      final currentRefreshToken = databaseService.accessToken;

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        debugPrint('No refresh token available to refresh.');
        return RefreshStatus.failedOther; // Bina token ke fail
      }

      debugPrint(
          'Attempting token refresh using refreshToken: ${currentRefreshToken.substring(0, min(8, currentRefreshToken.length))}...');

      // authApi.refreshToken call
      final response = await authApi.refreshToken(currentRefreshToken);

      // --- Token parsing logic ---
      String? newAccessToken;
      if (response.data is Map) {
        final data = response.data as Map;
        if (data['token'] is Map) {
          newAccessToken = (data['token'] as Map)['accessToken'] as String?;
        }
      }
      // --- End parsing ---

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await databaseService.putAccessToken(newAccessToken);
        debugPrint('Token refreshed and stored.');
        return RefreshStatus.success; // Success
      } else {
        debugPrint('Refresh response did not contain an access token.');
        return RefreshStatus.failedOther;
      }

    } catch (e) {
      // when authApi.refreshToken fail  (401, 404, etc.), error comes.
      debugPrint('refreshToken() caught an error: $e');

      if (e is DioException) {
        final errorData = e.response?.data;

        // SPECIFIC LOGOUT CONDITION
        if (errorData is Map && errorData['error'] == 'Invalid or expired refresh token') {
          debugPrint('Refresh token is confirmed invalid or expired. Returning failedInvalidToken.');
          return RefreshStatus.failedInvalidToken;
        }
      }

      // new error (500, network error, etc.)
      debugPrint('Refresh token failed due to other error (e.g., network). Returning failedOther.');
      return RefreshStatus.failedOther;
    }
  }

}
