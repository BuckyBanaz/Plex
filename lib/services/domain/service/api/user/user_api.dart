part of 'package:plex_user/services/domain/service/api/api_import.dart';

class UserApi {
  final Dio dio;
  UserApi(this.dio);

  final basePath = '';

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double heading,
    required double speed,
    required String recordedAt, // ISO 8601 format string
    required int langKey,
    required String apiKey,
  }) async {

    final response = await dio.put(
      '$basePath${ApiEndpoint.location}',
      data: {
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "heading": heading,
        "speed": speed,
        "recorded_at": recordedAt,
      },
      options: Options(
        headers: {
          'lang_id': langKey,
          'api_key': apiKey,
        },
      ),
    );

    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data)
        : {'message': response.data?.toString()};
  }


  Future<Map<String, dynamic>> createShipment({
    required String userId,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '$basePath/shipments/create',
        data: {
          "userId": userId,
          "originLat": originLat,
          "originLng": originLng,
          "destinationLat": destinationLat,
          "destinationLng": destinationLng,
          "weight": weight,
        },
      );

      return (response.data is Map<String, dynamic>)
          ? Map<String, dynamic>.from(response.data)
          : {'message': response.data?.toString()};
    } catch (e) {
      debugPrint('Error creating shipment: $e');
      return {'error': e.toString()};
    }
  }
}