// lib/models/corporate_register_model.dart
class CorporateRegisterModel {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String companyName;
  final String sector;
  final String commercialRegNo;
  final String taxRegNo;
  final String websiteUrl;
  final String country;
  final String city;
  final String district;
  final String street;
  final String buildingNo;
  final String postalCode;
  final String fullName;
  final String position;
  final String contactMobile;
  final String contactEmail;
  final int noOfEmployees;
  final int expectedShipmentVolume;

  CorporateRegisterModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.companyName,
    required this.sector,
    required this.commercialRegNo,
    required this.taxRegNo,
    required this.websiteUrl,
    required this.country,
    required this.city,
    required this.district,
    required this.street,
    required this.buildingNo,
    required this.postalCode,
    required this.fullName,
    required this.position,
    required this.contactMobile,
    required this.contactEmail,
    required this.noOfEmployees,
    required this.expectedShipmentVolume,
  });

  factory CorporateRegisterModel.fromJson(Map<String, dynamic> json) {
    return CorporateRegisterModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      password: json['password'] ?? '',
      companyName: json['companyName'] ?? '',
      sector: json['sector'] ?? '',
      commercialRegNo: json['commercialRegNo'] ?? '',
      taxRegNo: json['taxRegNo'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      street: json['street'] ?? '',
      buildingNo: json['buildingNo'] ?? '',
      postalCode: json['postalCode'] ?? '',
      fullName: json['fullName'] ?? '',
      position: json['position'] ?? '',
      contactMobile: json['contactMobile'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      noOfEmployees: json['noOfEmployees'] is int
          ? json['noOfEmployees']
          : int.tryParse(json['noOfEmployees']?.toString() ?? '') ?? 0,
      expectedShipmentVolume: json['expectedShipmentVolume'] is int
          ? json['expectedShipmentVolume']
          : int.tryParse(json['expectedShipmentVolume']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "mobile": mobile,
      "password": password,
      "companyName": companyName,
      "sector": sector,
      "commercialRegNo": commercialRegNo,
      "taxRegNo": taxRegNo,
      "websiteUrl": websiteUrl,
      "country": country,
      "city": city,
      "district": district,
      "street": street,
      "buildingNo": buildingNo,
      "postalCode": postalCode,
      "fullName": fullName,
      "position": position,
      "contactMobile": contactMobile,
      "contactEmail": contactEmail,
      "noOfEmployees": noOfEmployees,
      "expectedShipmentVolume": expectedShipmentVolume,
    };
  }
}
