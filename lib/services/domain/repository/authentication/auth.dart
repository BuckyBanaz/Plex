part of 'package:plex_user/services/domain/repository/repository_imports.dart';


class AuthRepository {
  final AuthApi authApi = Get.find<AuthApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await authApi.login(email: email, password: password);

      if (data == null || data['token'] == null || data['user'] == null) {
        throw Exception("Invalid response from server");
      }

      final token = data['token'];
      final userJson = data['user'];
      // Save token asynchronously but DO NOT block login return
      // unawaited(databaseService.putAccessToken(token));
      // unawaited(databaseService.putIsLogin(true));
      // unawaited(databaseService.putUser(userJson));

      final user = UserModel.fromJson(userJson);
      return user;
    } on DioError catch (dioError) {
      final msg = dioError.response?.data is Map
          ? (dioError.response?.data['message'] ?? dioError.response?.data['error'])
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
    final data = await authApi.register(name: name, email: email, password: password);
    if (data.containsKey('error')) throw Exception(data['error']);
    if (data.containsKey('message')) return data['message'] as String;
    throw Exception("Unexpected response from server");
  }

  Future<Map<String, dynamic>> registerDriver({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await authApi.registerDriver(name: name, email: email, password: password);
    if (response.statusCode == 201 && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    } else {
      final serverMsg = (response.data is Map)
          ? (response.data['error'] ?? response.data['message'])
          : 'Registration failed: ${response.statusCode}';
      throw Exception(serverMsg.toString());
    }
  }

  Future<String> registerCorporate({
    required CorporateRegisterModel model,
  }) async {
    final data = await authApi.registerCorporate(body: model.toJson());
    if (data.containsKey('error')) throw Exception(data['error']);
    if (data.containsKey('message')) return data['message'] as String;
    // fallback
    return data.values.join(' ');
  }

  Future<bool> verifyOtp({
    required String keyType,
    required String keyValue,
    required String otp,
  }) async {
    final response = await authApi.verifyOtp(keyType: keyType, keyValue: keyValue, otp: otp);
    if (response.statusCode == 200) return true;
    if (response.statusCode == 400 || response.statusCode == 401) return false;
    final msg = (response.data is Map) ? (response.data['message'] ?? response.data['error']) : null;
    throw Exception(msg?.toString() ?? 'OTP verification failed');
  }
}
