import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String userType;
  final bool isMobileVerified;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.isMobileVerified,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    userType: json['userType'],
    isMobileVerified: json['isMobileVerified'],
    isEmailVerified: json['isEmailVerified'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "userType": userType,
    "isMobileVerified": isMobileVerified,
    "isEmailVerified": isEmailVerified,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };

  String toRawJson() => json.encode(toJson());
  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));
}
