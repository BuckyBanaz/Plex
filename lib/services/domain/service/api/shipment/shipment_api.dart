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
    required String vehicleType,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
    required String weightUnit,
    required String notes,
    required Map<String, dynamic> pickup,
    required Map<String, dynamic> dropoff,
    required String paymentMethod,
    required String collectType, // "immediate" or "scheduled"
    DateTime? scheduledAt, // nullable
    List<String>? imageUrls, // optional
  }) async {
    try {
      // Build request body dynamically
      final Map<String, dynamic> payload = {
        "userId": userId,
        "vehicleType": vehicleType,
        "weight": "$weight $weightUnit",
        "notes": notes,
        "pickup": pickup,
        "dropoff": dropoff,
        "paymentMethod": paymentMethod,
        "collectTime": {
          "type": collectType,
          if (collectType == "scheduled" && scheduledAt != null)
            "scheduledAt": scheduledAt.toUtc().toIso8601String(),
        },
      };

      // ✅ Add image list only if available
      if (imageUrls != null && imageUrls.isNotEmpty) {
        payload["images"] = imageUrls;
      }

      final response = await dio.post(
        ApiEndpoint.createShipment,
        data: payload,
      );

      return (response.data is Map<String, dynamic>)
          ? Map<String, dynamic>.from(response.data)
          : {'message': response.data?.toString()};
    } catch (e) {
      debugPrint('Error creating shipment: $e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getShipments() async {
    try {
      final response = await dio.get(
        ApiEndpoint.shipment, // <-- ensure ApiEndpoint.shipments exists
      );

      // If backend returns an object with success/data
      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }

      // fallback: wrap as message
      return {'message': response.data?.toString()};
    } catch (e) {
      debugPrint('Error fetching shipments: $e');
      return {'error': e.toString()};
    }
  }

}
