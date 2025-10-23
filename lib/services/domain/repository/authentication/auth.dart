part of 'package:plex_user/services/domain/repository/repository_imports.dart';


class AuthRepository {
  final AuthApi authApi = Get.find<AuthApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();
  final DeviceInfoService deviceInfoService = Get.find<DeviceInfoService>();
  final LocaleController localeController = Get.find<LocaleController>();

  int get langKey {
    // Map locale to langKey required by API
    switch (localeController.current.value.toString()) {
      case 'en_US':
        return 1; // English
      case 'ar_SA':
        return 2; // Arabic/Saudi
      default:
        return 1;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await authApi.login(email: email, password: password,langKey: langKey);

      if (data == null || data['user'] == null) {
        throw Exception("Invalid response from server");
      }

      // store token only if present
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await databaseService.putAccessToken(token);
      } else {

        print("Auth token not present in login response");
      }

      final userJson = data['user'];
      final user = UserModel.fromJson(userJson);
      return user;
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
          langKey:langKey ,
          otpType : 'email'
      );


      final statusCode = response['statusCode'] ?? 200; // fallback 200 if not provided
      if (statusCode != 200 && statusCode != 201) {
        final error = response['error'] ?? 'Registration failed';
        throw Exception(error.toString());
      }

      // store api_key if available
      if (response.containsKey('api_key')) {
        await databaseService.putApiKey(response['api_key']);
      }

      // return success message
      return response['message']?.toString() ?? 'Registered successfully';
    } catch (e) {
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Registration failed';
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
      );

      // check status code
      final status = response.statusCode ?? 0;
      if (status != 200 && status != 201) {
        final serverMsg = (response.data is Map)
            ? (response.data['error'] ?? response.data['message'] ?? 'Unknown error')
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

      if (data == null) {
        throw Exception('No response from server');
      }

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
      if (response.statusCode == 400 || response.statusCode == 401) return false;

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

  /// Refreshes token using current token stored in DatabaseService.
  /// Returns true if refresh succeeded and token stored, false otherwise.
  Future<bool> refreshToken() async {
    try {
      final currentToken = databaseService.accessToken;
      if (currentToken == null || currentToken.isEmpty) {
        debugPrint('No current token available to refresh.');
        return false;
      }

      final response = await authApi.refreshToken(currentToken);

      if (response.statusCode == 200) {
        // Support both shapes:
        // 1) { "token": { "accessToken": "..." } }
        // 2) { "accessToken": "..." } or { "token": "..." }
        String? newToken;

        if (response.data is Map) {
          final data = response.data as Map;
          if (data['token'] is Map) {
            newToken = (data['token'] as Map)['accessToken'] as String?;
          } else if (data['accessToken'] is String) {
            newToken = data['accessToken'] as String;
          } else if (data['token'] is String) {
            newToken = data['token'] as String;
          }
        } else if (response.data is String) {
          newToken = response.data as String;
        }

        if (newToken != null && newToken.isNotEmpty) {
          await databaseService.putAccessToken(newToken);
          debugPrint('Token refreshed and stored.');
          return true;
        } else {
          debugPrint('Refresh response did not contain an access token.');
          return false;
        }
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        // refresh attempt invalid -> return false (caller will handle logout)
        return false;
      } else {
        debugPrint('Unexpected status code while refreshing token: ${response.statusCode}');
        return false;
      }
    } catch (e, st) {
      debugPrint('refreshToken() failed: $e');
      debugPrint(st.toString());
      return false;
    }
  }


}
