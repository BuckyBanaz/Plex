import 'dart:convert';

class LocationModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final double speed;
  final DateTime recordedAt;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.heading,
    required this.speed,
    required this.recordedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      heading: (json['heading'] ?? 0).toDouble(),
      speed: (json['speed'] ?? 0).toDouble(),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'heading': heading,
    'speed': speed,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
  };

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? heading,
    double? speed,
    DateTime? recordedAt,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

class VehicleModel {
  final int id;
  final String type;
  final String licenseNo;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.type,
    required this.licenseNo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      type: (json['type'] ?? json['vehicle_type'] ?? '').toString(),
      licenseNo: (json['licenseNo'] ?? json['license_no'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'licenseNo': licenseNo,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  VehicleModel copyWith({
    int? id,
    String? type,
    String? licenseNo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      type: type ?? this.type,
      licenseNo: licenseNo ?? this.licenseNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'VehicleModel(id: $id, type: $type, licenseNo: $licenseNo)';

  String toRawJson() => json.encode(toJson());
  factory VehicleModel.fromRawJson(String str) =>
      VehicleModel.fromJson(json.decode(str));
}

class DriverUserModel {
  final int id;
  final String name;
  final String email;
  final String userType;
  final bool isMobileVerified;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LocationModel location;
  final VehicleModel? vehicle; // optional because not all users may have vehicle

  DriverUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.isMobileVerified,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    this.vehicle,
  });

  factory DriverUserModel.fromJson(Map<String, dynamic> json) {
    return DriverUserModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: (json['userType'] ?? json['user_type'] ?? '').toString(),
      isMobileVerified:
      json['isMobileVerified'] ?? json['is_mobile_verified'] ?? false,
      isEmailVerified:
      json['isEmailVerified'] ?? json['is_email_verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      location: json['location'] != null
          ? LocationModel.fromJson(Map<String, dynamic>.from(json['location']))
          : LocationModel(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        heading: 0,
        speed: 0,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(Map<String, dynamic>.from(json['vehicle']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'isMobileVerified': isMobileVerified,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'location': location.toJson(),
    };

    if (vehicle != null) {
      map['vehicle'] = vehicle!.toJson();
    }

    return map;
  }

  DriverUserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? userType,
    bool? isMobileVerified,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    LocationModel? location,
    VehicleModel? vehicle,
  }) {
    return DriverUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      vehicle: vehicle ?? this.vehicle,
    );
  }

  // convenience helpers
  DriverUserModel markMobileVerified() =>
      copyWith(isMobileVerified: true);
  DriverUserModel markMobileUnverified() =>
      copyWith(isMobileVerified: false);
  DriverUserModel markEmailVerified() => copyWith(isEmailVerified: true);

  @override
  String toString() =>
      'DriverUserModel(id: $id, name: $name, email: $email, userType: $userType, vehicle: ${vehicle?.toString() ?? "none"})';

  String toRawJson() => json.encode(toJson());
  factory DriverUserModel.fromRawJson(String str) =>
      DriverUserModel.fromJson(json.decode(str));
}
