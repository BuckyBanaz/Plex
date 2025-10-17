
import 'dart:convert';

class FirebaseNotificationModel {
    FirebaseNotificationModel({
        this.path,
        this.id,
        this.type,
        this.userId,
    });

    String? path;
    String? id;
    String? type;
    String? userId;

    factory FirebaseNotificationModel.fromRawJson(String str) => FirebaseNotificationModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory FirebaseNotificationModel.fromJson(Map<String, dynamic> json) => FirebaseNotificationModel(
        path: json["path"],
        id: json["id"],
        type: json["type"],
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "path": path,
        "id": id,
        "type": type,
        "userId": userId,
    };
}
