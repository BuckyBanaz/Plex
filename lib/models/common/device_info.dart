
import 'dart:convert';

class DeviceInfoModel {
    DeviceInfoModel({
        required this.deviceId,
        // required this.firebaseToken,
        required this.deviceModel,
        required this.deviceOs,
        required this.appVersion,
    });

    String deviceId;
    // String firebaseToken;
    String deviceModel;
    String deviceOs;
    String appVersion;

    factory DeviceInfoModel.fromRawJson(String str) => DeviceInfoModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DeviceInfoModel.fromJson(Map<String, dynamic> json) => DeviceInfoModel(
        deviceId: json["deviceId"],
        // firebaseToken: json["firebaseToken"],
        deviceModel: json["deviceModel"],
        deviceOs: json["deviceOS"],
        appVersion: json["appVersion"],
    );

    Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        // "firebaseToken": firebaseToken,
        "deviceModel": deviceModel,
        "deviceOS": deviceOs,
        "appVersion": appVersion,
    };
}
