// lib/models/kyc_model.dart

/// KYC Response from backend (simplified - no OCR)
class KycResponse {
  final bool success;
  final String? message;
  final KycData? data;

  KycResponse({required this.success, this.message, this.data});

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null 
          ? KycData.fromJson(Map<String, dynamic>.from(json['data'])) 
          : null,
    );
  }
}

class KycData {
  final int? kycId;
  final int? driverId;
  final KycImages? images;
  final KycDocumentNumbers? documentNumbers;
  final String? status;

  KycData({
    this.kycId, 
    this.driverId, 
    this.images, 
    this.documentNumbers,
    this.status,
  });

  factory KycData.fromJson(Map<String, dynamic> json) {
    return KycData(
      kycId: _parseInt(json['kycId']),
      driverId: _parseInt(json['driverId']),
      images: json['images'] != null 
          ? KycImages.fromJson(Map<String, dynamic>.from(json['images'])) 
          : null,
      documentNumbers: json['documentNumbers'] != null 
          ? KycDocumentNumbers.fromJson(Map<String, dynamic>.from(json['documentNumbers'])) 
          : null,
      status: json['status']?.toString(),
    );
  }
}

class KycImages {
  final String? licenseUrl;
  final String? idCardUrl;
  final String? rcUrl;
  final String? driverUrl;

  KycImages({this.licenseUrl, this.idCardUrl, this.rcUrl, this.driverUrl});

  factory KycImages.fromJson(Map<String, dynamic> json) {
    return KycImages(
      licenseUrl: json['licenseUrl']?.toString(),
      idCardUrl: json['idCardUrl']?.toString(),
      rcUrl: json['rcUrl']?.toString(),
      driverUrl: json['driverUrl']?.toString(),
    );
  }
}

class KycDocumentNumbers {
  final String? licenseNumber;
  final String? idCardNumber;
  final String? rcNumber;

  KycDocumentNumbers({this.licenseNumber, this.idCardNumber, this.rcNumber});

  factory KycDocumentNumbers.fromJson(Map<String, dynamic> json) {
    return KycDocumentNumbers(
      licenseNumber: json['licenseNumber']?.toString(),
      idCardNumber: json['idCardNumber']?.toString(),
      rcNumber: json['rcNumber']?.toString(),
    );
  }
}

/// Driver Status Response
class DriverStatusResponse {
  final bool success;
  final String? message;
  final DriverStatusData? data;

  DriverStatusResponse({required this.success, this.message, this.data});

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null 
          ? DriverStatusData.fromJson(Map<String, dynamic>.from(json['data'])) 
          : null,
    );
  }
}

class DriverStatusData {
  final int? driverId;
  final String? kycStatus;
  final String? vehicleStatus;
  final bool? isVerified;
  final KycDocuments? documents;
  final VehicleInfo? vehicle;

  DriverStatusData({
    this.driverId,
    this.kycStatus,
    this.vehicleStatus,
    this.isVerified,
    this.documents,
    this.vehicle,
  });

  factory DriverStatusData.fromJson(Map<String, dynamic> json) {
    return DriverStatusData(
      driverId: _parseInt(json['driverId']),
      kycStatus: json['kycStatus']?.toString(),
      vehicleStatus: json['vehicleStatus']?.toString(),
      isVerified: json['isVerified'] == true,
      documents: json['documents'] != null 
          ? KycDocuments.fromJson(Map<String, dynamic>.from(json['documents'])) 
          : null,
      vehicle: json['vehicle'] != null 
          ? VehicleInfo.fromJson(Map<String, dynamic>.from(json['vehicle'])) 
          : null,
    );
  }
}

class KycDocuments {
  final String? licenseUrl;
  final String? idCardUrl;
  final String? rcUrl;
  final String? driverUrl;
  final String? licenseNumber;
  final String? idCardNumber;
  final String? rcNumber;

  KycDocuments({
    this.licenseUrl,
    this.idCardUrl,
    this.rcUrl,
    this.driverUrl,
    this.licenseNumber,
    this.idCardNumber,
    this.rcNumber,
  });

  factory KycDocuments.fromJson(Map<String, dynamic> json) {
    return KycDocuments(
      licenseUrl: json['licenseUrl']?.toString(),
      idCardUrl: json['idCardUrl']?.toString(),
      rcUrl: json['rcUrl']?.toString(),
      driverUrl: json['driverUrl']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      idCardNumber: json['idCardNumber']?.toString(),
      rcNumber: json['rcNumber']?.toString(),
    );
  }
}

class VehicleInfo {
  final int? id;
  final String? vehicleType;
  final String? ownerName;
  final String? fuelType;
  final String? vehicleImageUrl;

  VehicleInfo({
    this.id,
    this.vehicleType,
    this.ownerName,
    this.fuelType,
    this.vehicleImageUrl,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: _parseInt(json['id']),
      vehicleType: json['vehicleType']?.toString(),
      ownerName: json['ownerName']?.toString(),
      fuelType: json['fuelType']?.toString(),
      vehicleImageUrl: json['vehicleImageUrl']?.toString(),
    );
  }
}

// Helper function to parse int safely
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
