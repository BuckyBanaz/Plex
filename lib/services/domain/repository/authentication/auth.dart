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

      if (data == null || !data.containsKey('token') ||
          !data.containsKey('user')) {
        throw Exception("Invalid response from server");
      }

      final token = data['token'];
      final userJson = data['user'];
      final user = UserModel.fromJson(userJson);

      // Save to local DB
      await databaseService.putAccessToken(token);
      await databaseService.putIsLogin(true);
      await databaseService.putUser(userJson);

      return user;
    } on DioError catch (dioError) {
      // Dio-specific errors (network, timeout, response errors)
      final errorMessage = dioError.response?.data['message'] ??
          dioError.message;
      throw Exception("Login failed: $errorMessage");
    } catch (e) {
      // Other unexpected errors
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // REGISTER
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final data = await authApi.register(name: name, email: email, password: password);

      if (data.containsKey('error')) {
        // Agar user already registered hai
        throw Exception(data['error']); // "User already registered"
      }

      // Agar success hua
      if (data.containsKey('message')) {
        return data['message']; // "User registered successfully"
      }

      // Unexpected response
      throw Exception("Unexpected response from server");

    } catch (e) {
      rethrow;
    }
  }

}
