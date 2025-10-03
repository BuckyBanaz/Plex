part of 'package:plex_user/services/domain/service/api/api_import.dart';

class AuthApi {
  final Dio dio;
  AuthApi(this.dio);
  final basePath = '/auth';

  // LOGIN
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '${basePath}${ApiEndpoint.login}',
        data: {
          "email": email,
          "password": password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '${basePath}${ApiEndpoint.individualSignup}', // your register endpoint
        data: {
          "name": name,
          "email": email,
          "password": password,
        },
      );
      return response.data;
    } on DioError catch (dioError) {
      final errorMessage = dioError.response?.data['error'] ??
          dioError.message;
      throw Exception("Registration failed: $errorMessage");
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }














  // /// Otp Less Authentication
  // Future<Response<dynamic>> loginUser1(
  //     {required String deviceId,
  //     required String phone,
  //     required String country}) async {
  //   try {
  //     return await dio.post('$basePath/login',
  //         data: {'phone': phone, 'deviceId': deviceId, 'country': country});
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  //
  // /// Otp Verification
  // Future<Response<dynamic>> verifyOtp(
  //     {required String phone,
  //     required String otp,
  //     required String country,
  //     required DeviceInfoModel deviceInfo}) async {
  //   try {
  //     return await dio.post(
  //       '$basePath/verify',
  //       data: {
  //         'phone': phone,
  //         'role': 'mentee',
  //         'country': country,
  //         'deviceInfo': deviceInfo,
  //         'otp': otp
  //       },
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  //
  // /// Firebase Authentication
  // Future<Response<dynamic>> loginUser2(
  //     {required DeviceInfoModel deviceInfo,
  //     required String phone,
  //     required int countryCode,
  //     required String uid}) async {
  //   try {
  //     return await dio.post('$basePath/login2', data: {
  //       'device_info': deviceInfo,
  //       'phone': phone,
  //       'country_code': countryCode,
  //       'uid': uid
  //     });
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
