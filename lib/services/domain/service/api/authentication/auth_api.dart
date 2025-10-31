part of 'package:plex_user/services/domain/service/api/api_import.dart';



enum RefreshStatus {
  success,
  failedInvalidToken,
  failedOther,
}

class AuthApi {
  final Dio dio;
  AuthApi(this.dio);

  final basePath = '';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required int langKey,
  }) async {

    final response = await dio.post(
      '$basePath${ApiEndpoint.login}',
      data: {
        'email': email,
        'password': password},
      options: Options(
        headers: {
          'lang_id': langKey,},
      ),
    );

    // fast return
    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String deviceId,
    required String otpType , // default to email
    required int langKey,
  }) async {
    try {
      final response = await dio.post(
        '$basePath${ApiEndpoint.individualSignup}',
        options: Options(
          headers: {'lang_id': langKey},
        ),
        data: {
          'name': name,
          'email': email,
          'mobile': phone,
          'password': password,
          'deviceId': deviceId,
          'otpType': otpType,
        },
      );

      return (response.data is Map<String, dynamic>)
          ? Map<String, dynamic>.from(response.data)
          : {'message': response.data?.toString()};
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      if (serverData is Map && serverData.containsKey('error')) {
        throw Exception(serverData['error']);
      }
      throw Exception(dioError.message);
    }
  }


  Future<Response> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    required String licenseNo,
    required String deviceId,
    required int langKey,
  }) {
    return dio.post(
      '$basePath${ApiEndpoint.driverSignup}',
      options: Options(
        headers: {'lang_id': langKey},
      ),
      data: {
        "name": name,
        "email": email,
        "password": password,
        'deviceId': deviceId,
        "mobile": phone,
        "vehicleType": vehicleType,
        "licenseNo": licenseNo,
      },
    );
  }

  Future<Map<String, dynamic>> registerCorporate({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post(ApiEndpoint.corporateSignup, data: body);
      return (response.data is Map<String, dynamic>)
          ? Map<String, dynamic>.from(response.data)
          : {'message': response.data?.toString()};
    } on DioError catch (dioError) {
      final serverData = dioError.response?.data;
      if (serverData is Map && serverData.containsKey('error'))
        throw Exception(serverData['error']);
      if (serverData is String) throw Exception(serverData);
      throw Exception(dioError.message);
    }
  }

  Future<Response> verifyOtp({
    required String keyType,
    required String keyValue,
    required String apiKey,
    required String otp,
    required int langKey,
  }) {
    return dio.post(
      '$basePath${ApiEndpoint.verifyOtp}',
      options: Options(
        headers: {
          'api_key':apiKey,
          'lang_id': langKey,},
      ),
      data: {'keyType': keyType, 'keyValue': keyValue, 'otp': otp},
    );
  }


  Future<Response> refreshToken(String currentToken) {
    final options = Options(
      headers: {
        'token': currentToken,
      },

      extra: {
        'skipToken': true,
        'isRefreshCall': true,
      },
    );

    return dio.post('$basePath${ApiEndpoint.refreshToken}', options: options);
  }
}
