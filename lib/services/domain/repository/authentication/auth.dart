part of 'package:plex_user/services/domain/repository/repository_imports.dart';


class AuthRepository {
  final AuthApi authApi = Get.find<AuthApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();
  final DeviceInfoService deviceInfoService = Get.find<DeviceInfoService>();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await authApi.login(email: email, password: password);

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
    required String password,
  }) async {
    try {
      // fetch device id (may throw)
      final DeviceInfoModel deviceInfo = await deviceInfoService.getDeviceInfo();

      // call API (may throw / return various shapes)
      final dynamic data = await authApi.register(
        name: name,
        email: email,
        password: password,
        deviceId: deviceInfo.deviceId,
      );

      // guard against null response
      if (data == null) {
        throw Exception('No response from server');
      }

      // prefer Map<String, dynamic> handling
      if (data is Map<String, dynamic>) {
        // API error field
        if (data.containsKey('error') && data['error'] != null) {
          throw Exception(data['error'].toString());
        }

        // standard success message
        if (data.containsKey('message') && data['message'] != null) {
          return data['message'].toString();
        }

        // sometimes API nests result inside a "data" object
        if (data.containsKey('data') && data['data'] is Map) {
          final nested = data['data'] as Map;
          if (nested.containsKey('message') && nested['message'] != null) {
            return nested['message'].toString();
          }
        }
      }

      // if response is a plain string (rare)
      if (data is String && data.isNotEmpty) {
        return data;
      }

      // fallback
      throw Exception('Unexpected response from server');
    } catch (e, stack) {
      // debug logs - remove or guard in production
      debugPrint('register() failed: $e');
      debugPrint('$stack');

      // normalize network / Dio / http errors to user-friendly message
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Registration failed';
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
      DeviceInfoModel deviceInfo = await deviceInfoService.getDeviceInfo();

      final response = await authApi.registerDriver(
        name: name,
        email: email,
        phone: phone,
        password: password,
        deviceId: deviceInfo.deviceId,
      );

      if (response.statusCode == 201 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      } else {
        final serverMsg = (response.data is Map)
            ? (response.data['error'] ?? response.data['message'] ?? 'Unknown error')
            : 'Registration failed: ${response.statusCode}';
        throw Exception(serverMsg);
      }
    } catch (e, stackTrace) {
      // Log or handle errors properly
      debugPrint("Error during driver registration: $e");
      debugPrint("StackTrace: $stackTrace");

      // Rethrow a user-friendly error message
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
      final response = await authApi.verifyOtp(
        keyType: keyType,
        keyValue: keyValue,
        otp: otp,
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

}
