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
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return LocationModel(
      latitude: toDouble(json['latitude'] ?? json['lat'] ?? 0),
      longitude: toDouble(json['longitude'] ?? json['lng'] ?? json['lon'] ?? 0),
      accuracy: toDouble(json['accuracy'] ?? 0),
      heading: toDouble(json['heading'] ?? 0),
      speed: toDouble(json['speed'] ?? 0),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : (json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
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
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return VehicleModel(
      id: toInt(json['id'] ?? json['vehicle_id']),
      type: (json['type'] ?? json['vehicle_type'] ?? '').toString(),
      licenseNo: (json['licenseNo'] ?? json['license_no'] ?? json['license'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'licenseNo': licenseNo,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  @override
  String toString() => 'VehicleModel(id: $id, type: $type, licenseNo: $licenseNo)';
}

class BalanceModel {
  final int id;
  final num balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  BalanceModel({
    required this.id,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    return BalanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      balance: toNum(json['balance'] ?? 0),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'balance': balance,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
}

class DriverUserModel {
  final int id;
  final String name;
  final String email;
  final String userType;
  final String? mobile;
  final bool mobileVerified;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LocationModel location;
  final List<VehicleModel> vehicles;
  final BalanceModel? currentBalance;

  DriverUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.mobile,
    required this.mobileVerified,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
    required this.vehicles,
    this.currentBalance,
  });

  factory DriverUserModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    bool toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    String? parseMobile(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.toLowerCase() == 'null') return null;
      // if string contains 'null' prefix like "null890...", remove prefix
      final cleaned = s.replaceFirst(RegExp(r'^null', caseSensitive: false), '');
      return cleaned.isEmpty ? null : cleaned;
    }

    // parse vehicles: API might send array or single object or null
    List<VehicleModel> parseVehicles(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v
            .where((e) => e != null)
            .map<VehicleModel>((e) =>
            VehicleModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else if (v is Map) {
        return [VehicleModel.fromJson(Map<String, dynamic>.from(v))];
      }else if (v is String) {
        // maybe JSON string of list/object
        try {
          final decoded = jsonDecode(v);
          return parseVehicles(decoded);
        } catch (_) {
          return [];
        }
      }

      return [];
    }

    return DriverUserModel(
      id: toInt(json['id'] ?? json['user_id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      userType: (json['userType'] ?? json['user_type'] ?? '').toString(),
      mobile: parseMobile(json['mobile'] ?? json['phone'] ?? json['mobile_no']),
      mobileVerified: toBool(json['mobileVerified'] ?? json['mobile_verified'] ?? false),
      emailVerified: toBool(json['emailVerified'] ?? json['email_verified'] ?? false),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(0)),
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
      vehicles: parseVehicles(json['vehicle'] ?? json['vehicles']),
      currentBalance: json['currentBalance'] != null
          ? BalanceModel.fromJson(Map<String, dynamic>.from(json['currentBalance']))
          : (json['current_balance'] != null
          ? BalanceModel.fromJson(Map<String, dynamic>.from(json['current_balance']))
          : null),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'mobile': mobile,
      'mobileVerified': mobileVerified,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'location': location.toJson(),
      'vehicle': vehicles.map((v) => v.toJson()).toList(),
    };

    if (currentBalance != null) {
      map['currentBalance'] = currentBalance!.toJson();
    }

    return map;
  }

  DriverUserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? userType,
    String? mobile,
    bool? mobileVerified,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    LocationModel? location,
    List<VehicleModel>? vehicles,
    BalanceModel? currentBalance,
  }) {
    return DriverUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      mobile: mobile ?? this.mobile,
      mobileVerified: mobileVerified ?? this.mobileVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      vehicles: vehicles ?? this.vehicles,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  String toString() {
    return 'DriverUserModel(id: $id, name: $name, email: $email, userType: $userType, mobile: $mobile, vehicles: ${vehicles.length}, balance: ${currentBalance?.balance ?? 0})';
  }

  String toRawJson() => json.encode(toJson());
  factory DriverUserModel.fromRawJson(String str) =>
      DriverUserModel.fromJson(json.decode(str));
}
