

import 'dart:convert';
import 'dart:html';

class FileUploadModel {
    FileUploadModel({
        required this.requirement,
        required this.module,
    });

    List<Requirement> requirement;
    String module;

    factory FileUploadModel.fromRawJson(String str) => FileUploadModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory FileUploadModel.fromJson(Map<String, dynamic> json) => FileUploadModel(
        requirement: List<Requirement>.from(json["requirement"].map((x) => Requirement.fromJson(x))),
        module: json["module"],
    );

    Map<String, dynamic> toJson() => {
        "requirement": List<dynamic>.from(requirement.map((x) => x.toJson())),
        "module": module,
    };
}

class Requirement {
    Requirement({
      required this.order,
      required this.extension,
      this.asset
    });

    int order;
    String extension;
    File? asset;

    factory Requirement.fromRawJson(String str) => Requirement.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Requirement.fromJson(Map<String, dynamic> json) => Requirement(
        order: json["order"],
        extension: json["extension"],
    );

    Map<String, dynamic> toJson() => {
        "order": order,
        "extension": extension,
    };
}
