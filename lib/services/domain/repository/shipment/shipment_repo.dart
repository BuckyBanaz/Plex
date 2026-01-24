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
    required String paymentMethod,
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
        paymentMethod: paymentMethod,
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
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to fetch shipments',
          'raw': result,
        };
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

  Future<Map<String, dynamic>> acceptShipment({
    required int shipmentId,
    OrderModel? order,
    bool optimistic = true,
  }) async {
    try {
      // optimistic in-memory update (optional)
      OrderModel? originalOrderCopy;
      if (optimistic && order != null) {
        try {
          originalOrderCopy = OrderModel.fromJson({
            'id': order.id,
            'orderId': order.orderId,
            'status': order.status.value.toString(),
          });
          order.status.value = OrderStatus.Assigned;
        } catch (e) {
          debugPrint('Optimistic update skipped: $e');
        }
      }

      // call api (shipmentApi.acceptShipment should return a Map)
      final apiResult = await shipmentApi.acceptShipment(
        shipmentId: shipmentId,
      );

      // normalize to Map
      final Map<String, dynamic> raw = (apiResult is Map<String, dynamic>)
          ? apiResult
          : {'data': apiResult};

      // Try many places for statusCode & message (defensive)
      final int? statusCode = (raw['statusCode'] is int)
          ? raw['statusCode'] as int
          : (raw['raw'] is Map && raw['raw']['statusCode'] is int
                ? raw['raw']['statusCode'] as int
                : null);

      String extractMessage(dynamic obj) {
        try {
          if (obj == null) return '';
          if (obj is String && obj.isNotEmpty) return obj;
          if (obj is Map) {
            if (obj.containsKey('message') && obj['message'] != null)
              return obj['message'].toString();
            if (obj.containsKey('error') && obj['error'] != null)
              return obj['error'].toString();
            if (obj.containsKey('data')) {
              final d = obj['data'];
              if (d is Map && d.containsKey('message') && d['message'] != null)
                return d['message'].toString();
              if (d is String && d.isNotEmpty) return d;
            }
          }
          return obj.toString();
        } catch (_) {
          return '';
        }
      }

      // Check common candidates for server message
      String message = '';
      message = extractMessage(raw['message']) ?? '';
      if (message.isEmpty) message = extractMessage(raw['error']);
      if (message.isEmpty) message = extractMessage(raw['data']);
      if (message.isEmpty && raw['raw'] != null)
        message = extractMessage(raw['raw']);
      if (message.isEmpty && raw['raw'] is Map && raw['raw']['data'] != null)
        message = extractMessage(raw['raw']['data']);

      // If still empty, fallback to generic
      if (message.isEmpty) message = '';

      // treat any error presence or HTTP status >=400 as failure
      final bool hasErrorKey = raw.containsKey('error') && raw['error'] != null;
      final bool httpFailure = statusCode != null && statusCode >= 400;

      if (hasErrorKey || httpFailure) {
        // rollback optimistic in-memory
        if (optimistic && order != null && originalOrderCopy != null) {
          try {
            order.status.value = OrderStatus.Pending;
          } catch (e) {
            debugPrint('Rollback failed: $e');
          }
        }

        final Map<String, dynamic> result = {
          'success': false,
          'statusCode': statusCode,
          'message': message.isNotEmpty ? message : 'Request failed',
          'raw': raw,
          'error': raw['error'],
        };

        debugPrint('acceptShipment -> FAILURE result: $result');
        return result;
      }

      // success path — try parse shipment
      final dynamic serverData = raw['data'] ?? raw;
      OrderModel? updatedOrder;
      try {
        if (serverData is Map<String, dynamic>) {
          // if server wraps in {data:{shipment: {...}}}
          if (serverData['shipment'] is Map) {
            updatedOrder = OrderModel.fromJson(
              Map<String, dynamic>.from(serverData['shipment']),
            );
          } else {
            updatedOrder = OrderModel.fromJson(
              Map<String, dynamic>.from(serverData),
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to parse updated shipment: $e');
      }

      final Map<String, dynamic> successResult = {
        'success': true,
        'statusCode': statusCode,
        'message': message.isNotEmpty ? message : 'Shipment accepted',
        'raw': raw,
        if (updatedOrder != null) 'shipment': updatedOrder,
      };

      debugPrint('acceptShipment -> SUCCESS result: $successResult');
      return successResult;
    } catch (e, st) {
      debugPrint('Error in ShipmentRepository.acceptShipment: $e\n$st');
      try {
        if (order != null) order.status.value = OrderStatus.Pending;
      } catch (_) {}
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getDriverLocation({
    required String shipmentId,
  }) async {
    try {
      final result = await shipmentApi.getDriverLocation(
        shipmentId: shipmentId,
      );

      if (result.containsKey('error')) {
        debugPrint(
          'API error while fetching driver location: ${result['error']}',
        );
        return {'error': result['error']};
      }

      // Backend returns: { success: true, data: { liveLocation: { lat: ..., lng: ... } } }
      final success = result['success'] == true;
      final data = result['data'];

      if (!success) {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to fetch driver location',
        };
      }

      if (data == null || data is! Map) {
        return {'success': false, 'message': 'Invalid response data format'};
      }

      // Extract lat/lng from nested liveLocation object
      double? lat;
      double? lng;

      final liveLocation = data['liveLocation'];
      if (liveLocation is Map) {
        lat = (liveLocation['lat'] ?? liveLocation['latitude']) is num
            ? (liveLocation['lat'] ?? liveLocation['latitude']).toDouble()
            : null;
        lng =
            (liveLocation['lng'] ??
                    liveLocation['longitude'] ??
                    liveLocation['lon'])
                is num
            ? (liveLocation['lng'] ??
                      liveLocation['longitude'] ??
                      liveLocation['lon'])
                  .toDouble()
            : null;
      }

      // Fallback: try direct data level (for backward compatibility)
      if (lat == null || lng == null) {
        lat = (data['lat'] ?? data['latitude']) is num
            ? (data['lat'] ?? data['latitude']).toDouble()
            : null;
        lng = (data['lng'] ?? data['longitude'] ?? data['lon']) is num
            ? (data['lng'] ?? data['longitude'] ?? data['lon']).toDouble()
            : null;
      }

      if (lat != null && lng != null) {
        return {
          'success': true,
          'lat': lat,
          'lng': lng,
          'data': data,
          'timestamp': liveLocation is Map
              ? liveLocation['timestamp']
              : data['lastUpdated'],
        };
      }

      return {
        'success': false,
        'message': 'Driver location data not found in response',
      };
    } catch (e) {
      debugPrint('Error in repository while fetching driver location: $e');
      return {'error': e.toString()};
    }
  }



  Future<Map<String, dynamic>> updateShipment({
    required int orderId,
    required double lat,
    required double lng,
  }) async {
    try {
      final result = await shipmentApi.updateShipment(
        orderId: orderId,
        lat: lat,
        lng: lng,
      );

      debugPrint("Shipment updated successfully: $result");
      return result;
    } catch (e) {
      debugPrint("Error in repository while updating shipment: $e");
      return {'error': e.toString()};
    }
  }

}
