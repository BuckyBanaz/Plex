part of 'package:plex_user/services/domain/service/api/api_import.dart';

class ShipmentApi {
  final Dio dio;
  ShipmentApi(this.dio);


  Future<Map<String, dynamic>> estimateShipment({
    required String userId,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoint.estimateShipment,
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



  Future<Map<String, dynamic>> createShipment({
    required String userId,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoint.createShipment,
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
