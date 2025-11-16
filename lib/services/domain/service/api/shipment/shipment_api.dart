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


  // shipment_api.dart
  Future<Map<String, dynamic>> acceptShipment({
    required int shipmentId,
    String? token,
  }) async {
    try {
      final endpoint = ApiEndpoint.acceptShipment.replaceFirst(':id', shipmentId.toString());

      final Options options = Options(
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.json,
      );

      Response? response;
      try {
        response = await dio.post(endpoint, options: options, data: {});
      } catch (dioError) {
        // Rethrow as DioError? No — handle below.
        if (dioError is DioError) {
          final resp = dioError.response;
          final statusCode = resp?.statusCode;
          final respData = resp?.data;
          final String parsedMessage = _extractMessageFrom(respData) ?? dioError.message ?? 'Request failed';

          debugPrint('ShipmentApi.acceptShipment DioError: ${dioError.message}');
          return {
            'statusCode': statusCode,
            'data': respData,
            'message': parsedMessage,
            'error': dioError.message ?? dioError.toString(),
          };
        } else {
          debugPrint('ShipmentApi.acceptShipment non-Dio error: $dioError');
          return {'error': dioError.toString(), 'message': dioError.toString()};
        }
      }

      // At this point response is non-null (successful http status or 2xx/3xx)
      final int? statusCode = response?.statusCode;
      final dynamic respData = response?.data;
      final String parsedMessage = _extractMessageFrom(respData) ?? '';

      return {
        'statusCode': statusCode,
        'data': respData,
        'message': parsedMessage,
        'success': (respData is Map && respData['success'] != null)
            ? respData['success'] == true
            : (statusCode == 200 || statusCode == 201),
      };
    } catch (e, st) {
      debugPrint('ShipmentApi.acceptShipment unexpected error: $e\n$st');
      return {'error': e.toString(), 'message': e.toString()};
    }
  }

// helper: extract common server message safely
  String? _extractMessageFrom(dynamic respData) {
    try {
      if (respData == null) return null;
      if (respData is String && respData.isNotEmpty) return respData;
      if (respData is Map) {
        if (respData.containsKey('message') && respData['message'] != null) {
          return respData['message'].toString();
        }
        if (respData.containsKey('error') && respData['error'] != null) {
          return respData['error'].toString();
        }
        // If backend returns nested payload: {data: {message: '...'}}
        if (respData['data'] is Map && respData['data']['message'] != null) {
          return respData['data']['message'].toString();
        }
      }
      return respData.toString();
    } catch (e) {
      return null;
    }
  }

}
