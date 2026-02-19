// lib/services/domain/repository/admin/admin_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/api/admin/admin_api.dart';
import '../../service/app/app_service_imports.dart';

class AdminRepository {
  final AdminApi _adminApi = Get.find<AdminApi>();
  final DatabaseService _db = Get.find<DatabaseService>();

  String get _token => _db.accessToken ?? '';

  /// Get all pending KYC applications
  Future<List<KycApplication>> getPendingKycList() async {
    try {
      final response = await _adminApi.getPendingKycList(token: _token);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'] as List;
          return list.map((e) => KycApplication.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('getPendingKycList error: $e');
      return [];
    }
  }

  /// Get KYC details by ID
  Future<KycApplication?> getKycDetails(int kycId) async {
    try {
      final response = await _adminApi.getKycDetails(kycId: kycId, token: _token);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return KycApplication.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('getKycDetails error: $e');
      return null;
    }
  }

  /// Approve KYC
  Future<Map<String, dynamic>> approveKyc(int kycId, {String? remarks}) async {
    try {
      final response = await _adminApi.updateKycStatus(
        kycId: kycId,
        status: 'verified',
        remarks: remarks,
        token: _token,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'KYC approved successfully'};
      }
      return {'success': false, 'message': response.data['message'] ?? 'Failed to approve'};
    } on DioError catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Reject KYC
  Future<Map<String, dynamic>> rejectKyc(int kycId, {required String reason}) async {
    try {
      final response = await _adminApi.updateKycStatus(
        kycId: kycId,
        status: 'rejected',
        remarks: reason,
        token: _token,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'KYC rejected'};
      }
      return {'success': false, 'message': response.data['message'] ?? 'Failed to reject'};
    } on DioError catch (e) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

/// KYC Application Model
class KycApplication {
  final int kycId;
  final int driverId;
  final String status;
  final KycDocuments? documents;
  final VehicleInfo? vehicle;
  final DriverInfo? driver;
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  KycApplication({
    required this.kycId,
    required this.driverId,
    required this.status,
    this.documents,
    this.vehicle,
    this.driver,
    this.submittedAt,
    this.updatedAt,
  });

  factory KycApplication.fromJson(Map<String, dynamic> json) {
    return KycApplication(
      kycId: json['kycId'] ?? json['id'] ?? 0,
      driverId: json['driverId'] ?? 0,
      status: json['status'] ?? 'pending',
      documents: json['documents'] != null 
          ? KycDocuments.fromJson(json['documents']) 
          : null,
      vehicle: json['vehicle'] != null 
          ? VehicleInfo.fromJson(json['vehicle']) 
          : null,
      driver: json['driver'] != null 
          ? DriverInfo.fromJson(json['driver']) 
          : null,
      submittedAt: json['submittedAt'] != null 
          ? DateTime.tryParse(json['submittedAt'].toString()) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) 
          : null,
    );
  }
}

class KycDocuments {
  final String? idProofType;
  final String? idProofNumber;
  final String? idProofImageUrl;
  final String? profilePhotoUrl;
  final String? licenseUrl;
  final String? licenseNumber;
  final String? idCardUrl;
  final String? idCardNumber;
  final String? rcUrl;
  final String? rcNumber;
  final String? driverUrl;

  KycDocuments({
    this.idProofType,
    this.idProofNumber,
    this.idProofImageUrl,
    this.profilePhotoUrl,
    this.licenseUrl,
    this.licenseNumber,
    this.idCardUrl,
    this.idCardNumber,
    this.rcUrl,
    this.rcNumber,
    this.driverUrl,
  });

  factory KycDocuments.fromJson(Map<String, dynamic> json) {
    return KycDocuments(
      idProofType: json['idProofType'],
      idProofNumber: json['idProofNumber'],
      idProofImageUrl: json['idProofImageUrl'],
      profilePhotoUrl: json['profilePhotoUrl'],
      licenseUrl: json['licenseUrl'],
      licenseNumber: json['licenseNumber'],
      idCardUrl: json['idCardUrl'],
      idCardNumber: json['idCardNumber'],
      rcUrl: json['rcUrl'],
      rcNumber: json['rcNumber'],
      driverUrl: json['driverUrl'],
    );
  }

  String? get mainIdImage => idProofImageUrl ?? licenseUrl ?? idCardUrl;
  String? get mainIdNumber => idProofNumber ?? licenseNumber ?? idCardNumber;
  String? get profileImage => profilePhotoUrl ?? driverUrl;
}

class VehicleInfo {
  final int? id;
  final String? vehicleType;
  final String? ownerName;
  final String? licensePlate;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? fuelType;
  final int? vehicleAge;
  final String? vehicleImageUrl;

  VehicleInfo({
    this.id,
    this.vehicleType,
    this.ownerName,
    this.licensePlate,
    this.vehicleMake,
    this.vehicleModel,
    this.fuelType,
    this.vehicleAge,
    this.vehicleImageUrl,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: json['id'],
      vehicleType: json['vehicleType'],
      ownerName: json['ownerName'],
      licensePlate: json['licensePlate'] ?? json['licenseNo'],
      vehicleMake: json['vehicleMake'],
      vehicleModel: json['vehicleModel'],
      fuelType: json['fuelType'],
      vehicleAge: json['vehicleAge'],
      vehicleImageUrl: json['vehicleImageUrl'],
    );
  }
}

class DriverInfo {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  DriverInfo({this.id, this.name, this.email, this.phone});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
    );
  }
}
