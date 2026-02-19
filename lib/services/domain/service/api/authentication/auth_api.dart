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
    required String otpType ,
    required String fcmToken ,
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
          'fcmToken': fcmToken
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
    required String deviceId,
    required String fcmToken,
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
        'fcmToken': fcmToken,
        "otpType": 'email',

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

  Future<Response> resendOtp({
    required String keyType,
    required String keyValue,
    required int langKey,
  }) {
    return dio.post(
      '$basePath${ApiEndpoint.resendOtp}',
      options: Options(
        headers: {
          'lang_id': langKey,
        },
      ),
      data: {
        'keyType': keyType,
        'keyValue': keyValue,
      },
    );
  }
  Future<Response> forgotPassword({
    required String email,
    required int langKey,
  }) {
    return dio.post(
      '$basePath${ApiEndpoint.forgotPassword}',
      options: Options(
        headers: {
          'lang_id': langKey,
        },
      ),
      data: {
        "email":email
      }
    );
  }

  Future<Response> resetPassword({
    required String password,
    required String conPassword,
    required String token,
  }) {
    return dio.post(
        '$basePath${ApiEndpoint.resetPassword}',
        data: {
          "token": token,
          "newPassword": conPassword,
          "confirmPassword": password
        }
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

  Future<Response> uploadKyc({
    required String licenseNumber,
    required String idCardNumber,
    required String rcNumber,
    required File licenseImage,
    required File idCardImage,
    required File rcImage,
    required File driverImage,
    required String token,
    required int langKey,
  }) {
    final form = FormData.fromMap({
      'licenseNumber': licenseNumber,
      'idCardNumber': idCardNumber,
      'rcNumber': rcNumber,
      'licenseImage': MultipartFile.fromFileSync(
        licenseImage.path,
        filename: licenseImage.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(licenseImage.path)),
      ),
      'idCardImage': MultipartFile.fromFileSync(
        idCardImage.path,
        filename: idCardImage.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(idCardImage.path)),
      ),
      'rcImage': MultipartFile.fromFileSync(
        rcImage.path,
        filename: rcImage.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(rcImage.path)),
      ),
      'driverImage': MultipartFile.fromFileSync(
        driverImage.path,
        filename: driverImage.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(driverImage.path)),
      ),
    });

    return dio.post(
      '$basePath${ApiEndpoint.driverKyc}', // define driverKyc in ApiEndpoint
      data: form,
      options: Options(
        headers: {
          'token': token,
          'lang_id': langKey,
          'accept': '*/*',
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  // helper to guess mime type quickly
  String _guessMime(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  /// New KYC Flow - Submit ID Proof & Profile Photo (Step 1)
  Future<Response> submitDriverKycNew({
    required String idProofType,
    required String idProofNumber,
    required File idProofImage,
    required File profilePhoto,
    required String token,
  }) {
    // ========== DEBUG: KYC Step 1 ==========
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🆔 KYC STEP 1 SUBMISSION');
    debugPrint('╠══════════════════════════════════════════════════════════════');
    debugPrint('║ idProofType: $idProofType');
    debugPrint('║ idProofNumber: $idProofNumber');
    debugPrint('║ idProofImage: ${idProofImage.path}');
    debugPrint('║ profilePhoto: ${profilePhoto.path}');
    debugPrint('╚══════════════════════════════════════════════════════════════');

    final form = FormData.fromMap({
      'idProofType': idProofType,
      'idProofNumber': idProofNumber,
      'idProofImage': MultipartFile.fromFileSync(
        idProofImage.path,
        filename: idProofImage.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(idProofImage.path)),
      ),
      'profilePhoto': MultipartFile.fromFileSync(
        profilePhoto.path,
        filename: profilePhoto.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(profilePhoto.path)),
      ),
    });

    return dio.post(
      '$basePath/driver/kyc',
      data: form,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  /// Submit vehicle details after KYC (Step 2)
  Future<Response> submitVehicleDetails({
    required String ownerName,
    required String registeringAuthority,
    required String vehicleType,
    required String fuelType,
    required int vehicleAge,
    File? vehicleImage,
    String? licensePlate,
    String? vehicleMake,
    String? vehicleModel,
    required String token,
  }) {
    // ========== DEBUG: Vehicle Details ==========
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚗 VEHICLE DETAILS SUBMISSION');
    debugPrint('╠══════════════════════════════════════════════════════════════');
    debugPrint('║ ownerName: $ownerName');
    debugPrint('║ registeringAuthority: $registeringAuthority');
    debugPrint('║ vehicleType: $vehicleType');
    debugPrint('║ fuelType: $fuelType');
    debugPrint('║ vehicleAge: $vehicleAge');
    debugPrint('║ licensePlate: $licensePlate');
    debugPrint('║ vehicleMake: $vehicleMake');
    debugPrint('║ vehicleModel: $vehicleModel');
    debugPrint('║ vehicleImage: ${vehicleImage?.path}');
    debugPrint('╚══════════════════════════════════════════════════════════════');

    final Map<String, dynamic> formMap = {
      'ownerName': ownerName,
      'registeringAuthority': registeringAuthority,
      'vehicleType': vehicleType,
      'fuelType': fuelType,
      'vehicleAge': vehicleAge,
    };

    // Add new fields
    if (licensePlate != null && licensePlate.isNotEmpty) {
      formMap['licensePlate'] = licensePlate;
    }
    if (vehicleMake != null && vehicleMake.isNotEmpty) {
      formMap['vehicleMake'] = vehicleMake;
    }
    if (vehicleModel != null && vehicleModel.isNotEmpty) {
      formMap['vehicleModel'] = vehicleModel;
    }

    if (vehicleImage != null) {
      formMap['vehicleImage'] = MultipartFile.fromFileSync(
        vehicleImage.path,
        filename: vehicleImage.path.split(Platform.pathSeparator).last,
        contentType: MediaType.parse(_guessMime(vehicleImage.path)),
      );
    }

    final form = FormData.fromMap(formMap);

    return dio.post(
      '$basePath/driver/vehicle-details',
      data: form,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
        contentType: 'multipart/form-data',
      ),
    );
  }

  /// Get driver KYC and vehicle status
  Future<Response> getDriverStatus({required String token}) {
    return dio.get(
      '$basePath/driver/status',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      ),
    );
  }

}
