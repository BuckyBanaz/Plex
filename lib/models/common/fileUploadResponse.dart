
import 'dart:convert';

class FileUploadResponseModel {
    FileUploadResponseModel({
        required this.id,
        required this.url,
        required this.key,
        required this.order,
        required this.extension,
    });

    String id;
    String url;
    String key;
    int order;
    String extension;

    factory FileUploadResponseModel.fromRawJson(String str) => FileUploadResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory FileUploadResponseModel.fromJson(Map<String, dynamic> json) => FileUploadResponseModel(
        id: json["id"],
        url: json["url"],
        key: json["key"],
        order: json["order"],
        extension: json["extension"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "key": key,
        "order": order,
        "extension": extension,
    };
}
