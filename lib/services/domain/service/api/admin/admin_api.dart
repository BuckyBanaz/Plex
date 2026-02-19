// lib/services/domain/service/api/admin/admin_api.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' as gt;
import 'package:plex_user/constant/api_endpoint.dart';
import '../../app/app_service_imports.dart';
import '../api_import.dart';

class AdminApi {
  final Dio dio = gt.Get.find<ApiService>().dio;
  final String basePath = ApiEndpoint.baseUrl;

  /// Get all pending KYC applications
  Future<Response> getPendingKycList({required String token}) {
    return dio.get(
      '$basePath/admin/kyc/pending',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      ),
    );
  }

  /// Get KYC details by ID
  Future<Response> getKycDetails({
    required int kycId,
    required String token,
  }) {
    return dio.get(
      '$basePath/admin/kyc/$kycId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      ),
    );
  }

  /// Update KYC status (approve/reject)
  Future<Response> updateKycStatus({
    required int kycId,
    required String status,
    String? remarks,
    required String token,
  }) {
    return dio.patch(
      '$basePath/admin/kyc/$kycId/status',
      data: {
        'status': status,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// Update driver status (final approval after vehicle details)
  Future<Response> updateDriverStatus({
    required int driverId,
    required String status,
    required String token,
  }) {
    return dio.put(
      '$basePath/admin/driver/$driverId/status',
      data: {'status': status},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
