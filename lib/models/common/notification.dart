part of 'package:talecto/model/model_imports.dart';


class NotificationModel {
    NotificationModel({
        required this.id,
        required this.hasRead,
        required this.createdAt,
        required this.title,
        required this.body,
        required this.image,
        required this.payload,
    });

    final String id;
    final DateTime createdAt;
    final String title;
    final String? body;
    final String? image;
    final Payload? payload;
     bool hasRead;
     bool isDeleted = false;

     void read() => hasRead = !hasRead;
     void delete() => isDeleted = true;

    NotificationModel copyWith({ String? id, bool? hasRead, DateTime? createdAt,String? body, String? image, Payload? payload, String? title}) {
        return NotificationModel(
            id: id ?? this.id,
            hasRead: hasRead ?? this.hasRead,
            createdAt: createdAt ?? this.createdAt,
            body: body ?? this.body,
            title: title ?? this.title,
            image: image ?? this.image,
            payload: payload ?? this.payload,
        );
    }

    factory NotificationModel.fromJson(Map<String, dynamic> json){ 
        return NotificationModel(
            id: json["notificationId"],
            hasRead: json["hasRead"],
            createdAt: DateTime.parse(json["createdAt"]),
            title: json["title"],
            body: json["body"],
            image: json["image"],
            payload: json["payload"] == null ? null : Payload.fromJson(json["payload"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "notificationId": id,
        "hasRead": hasRead,
        "createdAt": createdAt.toIso8601String(),
        "title": title,
        "body": body,
        "image": image,
        "payload": payload?.toJson(),
    };
}

class Payload {
    Payload({ required this.path, });
    final String? path;
    Payload copyWith({ String? path }) { return Payload( path: path ?? this.path ); }
    factory Payload.fromJson(Map<String, dynamic> json){  return Payload( path: json["path"] ); }
    Map<String, dynamic> toJson() => { "path": path };
}
