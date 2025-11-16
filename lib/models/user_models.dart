import 'dart:convert';
class UserModel {
  final int id;
  final String name;
  final String email;
  final String userType;
  final String mobile;
  final bool mobileVerified;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AddressModel> address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.mobile,
    required this.mobileVerified,
    required this.emailVerified,
    this.createdAt,
    this.updatedAt,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    userType: json['userType'] ?? '',
    mobile: json['mobile'] ?? '',
    mobileVerified: json['mobileVerified'] ?? false,
    emailVerified: json['emailVerified'] ?? false,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    // FIXED: use lowercase 'updatedAt'
    updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    address: (json['address'] is List)
        ? (json['address'] as List).map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "userType": userType,
    "mobile": mobile,
    "mobileVerified": mobileVerified,
    "emailVerified": emailVerified,
    "createdAt": createdAt?.toIso8601String(),
    // FIXED: lowercase 'updatedAt'
    "updatedAt": updatedAt?.toIso8601String(),
    "address": address.map((x) => x.toJson()).toList(),
  };

  String toRawJson() => json.encode(toJson());
  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));
}

class AddressModel {
  final int? id;
  final String? address;
  final String? addressAs;
  final String? landmark;
  final String? locality;
  final bool isDefault;
  final LocationModel? location;

  AddressModel({
    this.id,
    this.address,
    this.addressAs,
    this.landmark,
    this.locality,
    this.isDefault = false,
    this.location,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'],
    address: json['address'],
    addressAs: json['addressAs'],
    landmark: json['landmark'],
    locality: json['locality'],
    isDefault: json['isDefault'] ?? false,
    location: json['location'] != null
        ? LocationModel.fromJson(json['location'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "address": address,
    "addressAs": addressAs,
    "landmark": landmark,
    "locality": locality,
    "isDefault": isDefault,
    "location": location?.toJson(),
  };
}

class LocationModel {
  final double latitude;
  final double longitude;

  LocationModel({
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}