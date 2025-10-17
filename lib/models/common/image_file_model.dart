part of 'package:talecto/model/model_imports.dart';

class ImageFile {
  ImageFile({
    required this.order,
    required this.url,
  });

  final int order;
  final String url;

  factory ImageFile.fromJson(Map<String, dynamic> json) {
    return ImageFile(
      order: json['order'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}
