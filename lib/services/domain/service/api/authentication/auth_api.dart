part of 'package:plex_user/services/domain/service/api/api_import.dart';


class AuthApi {
  final Dio dio;
  AuthApi(this.dio);

  final basePath = '';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post('$basePath${ApiEndpoint.login}', data: {'email': email, 'password': password});
    // fast return
    return (response.data is Map<String, dynamic>) ? Map<String, dynamic>.from(response.data) : {'message': response.data?.toString()};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post('$basePath${ApiEndpoint.individualSignup}', data: {'name': name, 'email': email, 'password': password});
      return (response.data is Map<String, dynamic>) ? Map<String, dynamic>.from(response.data) : {'message': response.data?.toString()};
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      if (serverData is Map && serverData.containsKey('error')) throw Exception(serverData['error']);
      throw Exception(dioError.message);
    }
  }

  Future<Response> registerDriver({
    required String name,
    required String email,
    required String password,
  }) {
    return dio.post('$basePath${ApiEndpoint.driverSignup}', data: {
      "name": name,
      "email": email,
      "password": password,
      "mobile": "9999999999",
      "vehicleType": "car",
      "licenseNo": "DL12345",
    });
  }

  Future<Map<String, dynamic>> registerCorporate({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post(ApiEndpoint.corporateSignup, data: body);
      return (response.data is Map<String, dynamic>) ? Map<String, dynamic>.from(response.data) : {'message': response.data?.toString()};
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      if (serverData is Map && serverData.containsKey('error')) throw Exception(serverData['error']);
      if (serverData is String) throw Exception(serverData);
      throw Exception(dioError.message);
    }
  }

  Future<Response> verifyOtp({
    required String keyType,
    required String keyValue,
    required String otp,
  }) {
    return dio.post('$basePath${ApiEndpoint.verifyOtp}', data: {'keyType': keyType, 'keyValue': keyValue, 'otp': otp});
  }
}
