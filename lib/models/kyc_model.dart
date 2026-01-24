// lib/models/kyc_model.dart
class KycResponse {
  final bool success;
  final String? message;
  final KycData? data;

  KycResponse({required this.success, this.message, this.data});

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null ? KycData.fromJson(Map<String, dynamic>.from(json['data'])) : null,
    );
  }
}

class KycData {
  final int? kycId;
  final int? driverId;
  final KycImages? images;
  final ExtractedText? extractedText;
  final Map<String, dynamic>? validation;

  KycData({this.kycId, this.driverId, this.images, this.extractedText, this.validation});

  factory KycData.fromJson(Map<String, dynamic> json) {
    return KycData(
      kycId: json['kycId'] is int ? json['kycId'] : int.tryParse(json['kycId']?.toString() ?? ''),
      driverId: json['driverId'] is int ? json['driverId'] : int.tryParse(json['driverId']?.toString() ?? ''),
      images: json['images'] != null ? KycImages.fromJson(Map<String, dynamic>.from(json['images'])) : null,
      extractedText: json['extractedText'] != null ? ExtractedText.fromJson(Map<String, dynamic>.from(json['extractedText'])) : null,
      validation: json['validation'] is Map ? Map<String, dynamic>.from(json['validation']) : null,
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

class ExtractedText {
  final LicenseText? license;
  final IdCardText? idCard;
  final RcText? rc;

  ExtractedText({this.license, this.idCard, this.rc});

  factory ExtractedText.fromJson(Map<String, dynamic> json) {
    return ExtractedText(
      license: json['license'] != null ? LicenseText.fromJson(Map<String, dynamic>.from(json['license'])) : null,
      idCard: json['idCard'] != null ? IdCardText.fromJson(Map<String, dynamic>.from(json['idCard'])) : null,
      rc: json['rc'] != null ? RcText.fromJson(Map<String, dynamic>.from(json['rc'])) : null,
    );
  }
}

class LicenseText {
  final String? licenseNumber;
  final String? dob;
  final String? issueDate;
  final String? validTill;
  final String? name;
  final String? fatherName;

  LicenseText({this.licenseNumber, this.dob, this.issueDate, this.validTill, this.name, this.fatherName});

  factory LicenseText.fromJson(Map<String, dynamic> json) {
    return LicenseText(
      licenseNumber: json['licenseNumber']?.toString(),
      dob: json['dob']?.toString(),
      issueDate: json['issueDate']?.toString(),
      validTill: json['validTill']?.toString(),
      name: json['name']?.toString(),
      fatherName: json['fatherName']?.toString(),
    );
  }
}

class IdCardText {
  final String? aadhaarNumber;
  final String? name;
  final String? mobile;
  final String? dob;
  final String? gender;

  IdCardText({this.aadhaarNumber, this.name, this.mobile, this.dob, this.gender});

  factory IdCardText.fromJson(Map<String, dynamic> json) {
    return IdCardText(
      aadhaarNumber: json['aadhaarNumber']?.toString(),
      name: json['name']?.toString(),
      mobile: json['mobile']?.toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
    );
  }
}

class RcText {
  final String? regNumber;
  final String? ownerName;
  final String? engineNumber;
  final String? fuelType;
  final String? regDate; // optional - add if backend includes it
  final String? regValidity; // optional

  RcText({this.regNumber, this.ownerName, this.engineNumber, this.fuelType, this.regDate, this.regValidity});

  factory RcText.fromJson(Map<String, dynamic> json) {
    return RcText(
      regNumber: json['regNumber']?.toString(),
      ownerName: json['ownerName']?.toString(),
      engineNumber: json['engineNumber']?.toString(),
      fuelType: json['fuelType']?.toString(),
      regDate: json['regDate']?.toString(),
      regValidity: json['regValidity']?.toString(),
    );
  }
}
