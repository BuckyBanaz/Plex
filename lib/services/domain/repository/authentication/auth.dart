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


  Future<KycResponse> submitDriverKyc({
    required String licenseNumber,
    required String idCardNumber,
    required String rcNumber,
    required File licenseImage,
    required File idCardImage,
    required File rcImage,
    required File driverImage,
  }) async {
    try {
      final token = databaseService.accessToken ?? '';
      final response = await authApi.uploadKyc(
        licenseNumber: licenseNumber,
        idCardNumber: idCardNumber,
        rcNumber: rcNumber,
        licenseImage: licenseImage,
        idCardImage: idCardImage,
        rcImage: rcImage,
        driverImage: driverImage,
        token: token,
        langKey: langKey,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final kycResponse = KycResponse.fromJson(body);
          return kycResponse;
        } else if (body is String) {
          throw Exception('Unexpected KYC response: $body');
        } else {
          // sometimes dio gives LinkedHashMap; convert then parse
          final map = Map<String, dynamic>.from(body as Map);
          return KycResponse.fromJson(map);
        }
      } else {
        final msg = (response.data is Map) ? (response.data['message'] ?? response.data['error']) : 'KYC upload failed';
        throw Exception(msg?.toString() ?? 'KYC upload failed with status ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      final message = (serverData is Map) ? (serverData['message'] ?? serverData['error']) : dioError.message;
      debugPrint('submitDriverKyc() DioError: $message');
      throw Exception(message?.toString() ?? 'Network error during KYC upload');
    } catch (e, st) {
      debugPrint('submitDriverKyc() error: $e\n$st');
      throw Exception('KYC submission failed: ${e.toString()}');
    }
  }

  /// Submit vehicle details after KYC
  Future<Map<String, dynamic>> submitVehicleDetails({
    required String ownerName,
    required String registeringAuthority,
    required String vehicleType,
    required String fuelType,
    required int vehicleAge,
    File? vehicleImage,
    String? licensePlate,
    String? vehicleMake,
    String? vehicleModel,
  }) async {
    try {
      final token = databaseService.accessToken ?? '';
      final response = await authApi.submitVehicleDetails(
        ownerName: ownerName,
        registeringAuthority: registeringAuthority,
        vehicleType: vehicleType,
        fuelType: fuelType,
        vehicleAge: vehicleAge,
        vehicleImage: vehicleImage,
        licensePlate: licensePlate,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          return body;
        } else if (body is Map) {
          return Map<String, dynamic>.from(body);
        }
        return {'success': true, 'message': 'Vehicle details submitted'};
      } else {
        final msg = (response.data is Map) 
            ? (response.data['message'] ?? response.data['error']) 
            : 'Vehicle details submission failed';
        throw Exception(msg?.toString() ?? 'Failed with status ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      final message = (serverData is Map) 
          ? (serverData['message'] ?? serverData['error']) 
          : dioError.message;
      debugPrint('submitVehicleDetails() DioError: $message');
      throw Exception(message?.toString() ?? 'Network error during vehicle details submission');
    } catch (e, st) {
      debugPrint('submitVehicleDetails() error: $e\n$st');
      throw Exception('Vehicle details submission failed: ${e.toString()}');
    }
  }

  /// Get driver KYC and vehicle status
  Future<Map<String, dynamic>> getDriverStatus() async {
    try {
      final token = databaseService.accessToken ?? '';
      final response = await authApi.getDriverStatus(token: token);

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          return body;
        } else if (body is Map) {
          return Map<String, dynamic>.from(body);
        }
        return {'success': false, 'message': 'Invalid response'};
      } else {
        throw Exception('Failed to get driver status');
      }
    } catch (e) {
      debugPrint('getDriverStatus() error: $e');
      throw Exception('Failed to get driver status: ${e.toString()}');
    }
  }

  /// Refresh driver status from backend and update local storage
  /// Returns the new kycStatus
  Future<String> refreshAndUpdateDriverStatus() async {
    try {
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 🔄 REFRESHING DRIVER STATUS');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      
      final response = await getDriverStatus();
      
      if (response['success'] == true) {
        final data = response['data'];
        final kycStatus = data?['kycStatus'] ?? 'not_submitted';
        
        debugPrint('║ Backend kycStatus: $kycStatus');
        
        // Update local driver model with new kycStatus
        final currentDriver = databaseService.driver;
        if (currentDriver != null) {
          final updatedDriver = DriverUserModel(
            id: currentDriver.id,
            name: currentDriver.name,
            email: currentDriver.email,
            userType: currentDriver.userType,
            mobile: currentDriver.mobile,
            kycStatus: kycStatus,
            mobileVerified: currentDriver.mobileVerified,
            emailVerified: currentDriver.emailVerified,
            createdAt: currentDriver.createdAt,
            updatedAt: currentDriver.updatedAt,
            location: currentDriver.location,
            vehicles: currentDriver.vehicles,
            currentBalance: currentDriver.currentBalance,
          );
          
          await databaseService.putDriver(updatedDriver);
          debugPrint('║ Local driver kycStatus updated to: $kycStatus');
        }
        
        // Update isKycDone flag
        if (kycStatus == 'verified') {
          databaseService.putKycDone(true);
        } else if (kycStatus == 'pending' || kycStatus == 'awaiting_approval') {
          databaseService.putKycDone(true); // submitted but not verified
        } else {
          databaseService.putKycDone(false);
        }
        
        debugPrint('╚══════════════════════════════════════════════════════════════');
        return kycStatus;
      }
      
      return 'not_submitted';
    } catch (e) {
      debugPrint('refreshAndUpdateDriverStatus() error: $e');
      return 'not_submitted';
    }
  }

  /// NEW: Submit Driver KYC - Step 1 (ID Proof + Profile Photo)
  Future<Map<String, dynamic>> submitDriverKycNew({
    required String idProofType,
    required String idProofNumber,
    required File idProofImage,
    required File profilePhoto,
  }) async {
    try {
      final token = databaseService.accessToken ?? '';
      final response = await authApi.submitDriverKycNew(
        idProofType: idProofType,
        idProofNumber: idProofNumber,
        idProofImage: idProofImage,
        profilePhoto: profilePhoto,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          return body;
        } else if (body is Map) {
          return Map<String, dynamic>.from(body);
        }
        return {'success': true, 'message': 'KYC submitted successfully'};
      } else {
        final msg = (response.data is Map) 
            ? (response.data['message'] ?? response.data['error']) 
            : 'KYC submission failed';
        throw Exception(msg?.toString() ?? 'Failed with status ${response.statusCode}');
      }
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      final message = (serverData is Map) 
          ? (serverData['message'] ?? serverData['error']) 
          : dioError.message;
      debugPrint('submitDriverKycNew() DioError: $message');
      return {'success': false, 'message': message?.toString() ?? 'Network error'};
    } catch (e, st) {
      debugPrint('submitDriverKycNew() error: $e\n$st');
      return {'success': false, 'message': 'KYC submission failed: ${e.toString()}'};
    }
  }

}
