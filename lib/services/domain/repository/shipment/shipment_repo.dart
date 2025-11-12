part of 'package:plex_user/services/domain/repository/repository_imports.dart';

class ShipmentRepository {
  final ShipmentApi shipmentApi = Get.find<ShipmentApi>();
  final DatabaseService databaseService = Get.find<DatabaseService>();

  Future<Map<String, dynamic>> estimateShipment({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
  }) async {
    try {
      // Fetch userId and token from database service
      final userId = databaseService.user!.id.toString();

      final result = await shipmentApi.estimateShipment(
        userId: userId,
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        weight: weight,
      );

      debugPrint("Shipment estimation get successfully: $result");
      return result;
    } catch (e) {
      debugPrint("Error in repository while estimation of shipment: $e");
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createShipment({
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
    // required String paymentMethod,
    required String collectType, // "immediate" or "scheduled"
    DateTime? scheduledAt, // optional
    List<String>? imageUrls, // optional
  }) async {
    try {
      // Fetch userId from database (local storage or firebase)
      final userId = databaseService.user!.id.toString();

      final result = await shipmentApi.createShipment(
        userId: userId,
        vehicleType: vehicleType,
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        weight: weight,
        weightUnit: weightUnit,
        notes: notes,
        pickup: pickup,
        dropoff: dropoff,
        paymentMethod: "stripe",
        collectType: collectType,
        scheduledAt: scheduledAt,
        imageUrls: imageUrls,
      );

      debugPrint("✅ Shipment created successfully: $result");
      return result;
    } catch (e) {
      debugPrint("❌ Error in repository while creating shipment: $e");
      return {'error': e.toString()};
    }
  }


  Future<Map<String, dynamic>> getShipments({
    bool parseToModels = true, // if you want raw response, set false
  }) async {
    try {
      // Try to get token from databaseService; adjust property name if different

      final result = await shipmentApi.getShipments();

      if (result.containsKey('error')) {
        debugPrint('API error while fetching shipments: ${result['error']}');
        return {'error': result['error']};
      }

      // Backend likely returns: { success: true, message: "...", data: [ {..}, ... ] }
      final success = result['success'] == true;
      final data = result['data'];

      if (!success) {
        // return server-provided message if any
        return {'success': false, 'message': result['message'] ?? 'Failed to fetch shipments', 'raw': result};
      }

      if (data == null) {
        return {'success': true, 'shipments': <OrderModel>[]};
      }

      // If caller wants raw JSON, return it
      if (!parseToModels) {
        return {'success': true, 'data': data};
      }

      // Parse list into OrderModel objects
      final List<OrderModel> orders = [];
      if (data is List) {
        for (final item in data) {
          try {
            if (item is Map<String, dynamic>) {
              orders.add(OrderModel.fromJson(item));
            } else {
              // sometimes API wraps under 'shipment' key
              if (item is Map) {
                final map = Map<String, dynamic>.from(item as Map);
                orders.add(OrderModel.fromJson(map));
              }
            }
          } catch (e) {
            debugPrint('Failed to parse order item: $e -- item: $item');
            // skip malformed item
          }
        }
      } else {
        // data not a list, attempt single object parse
        try {
          if (data is Map<String, dynamic>) {
            orders.add(OrderModel.fromJson(data));
          } else if (data is Map) {
            orders.add(OrderModel.fromJson(Map<String, dynamic>.from(data)));
          }
        } catch (e) {
          debugPrint('Failed to parse single shipment object: $e');
        }
      }

      return {'success': true, 'shipments': orders};
    } catch (e) {
      debugPrint('Error in repository while fetching shipments: $e');
      return {'error': e.toString()};
    }
  }
}
