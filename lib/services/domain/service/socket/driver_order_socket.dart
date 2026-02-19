// services/domain/service/socket/driver_order_socket.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../models/driver_order_model.dart';
import 'socket_service.dart';

class DriverOrderSocket {
  final SocketService socketService = Get.find<SocketService>();

  // Reactive orders list exposed to controllers
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  // Subscriptions (for any stream-based usage within this class)
  final List<StreamSubscription> _subs = [];

  // Dedup map for newShipment -> last seen
  final Map<String, DateTime> _recentShipments = {};

  DriverOrderSocket();

  /// Start listening to socket events (this also assumes socketService.connect(...) already called).
  void start() {
    final sock = socketService.socket;
    if (sock == null) {
      debugPrint(
        'DriverOrderSocket.start: socket is null — make sure SocketService.connect was called',
      );
      return;
    }

    debugPrint('DriverOrderSocket: setting up listeners on raw socket');

    // 1) existingShipments - keep the central cache in socketService and also parse into orders
    socketService.on('existingShipments', (data) {
      debugPrint(
        'DriverOrderSocket: existingShipments received (${(data as List?)?.length ?? 0})',
      );
      try {
        final list = List<dynamic>.from(data ?? []);
        // update central cache (optional)
        socketService.existingShipments.assignAll(list);

        // parse and filter - only show pending orders (not taken/completed)
        final parsed = list
            .map((j) => OrderModel.fromJson(Map<String, dynamic>.from(j)))
            .where((o) => _isAvailableOrder(o.status.value))
            .toList();
        orders.assignAll(parsed);
        debugPrint(
          'DriverOrderSocket: parsed ${parsed.length} available orders',
        );
      } catch (e) {
        debugPrint('DriverOrderSocket: error parsing existingShipments: $e');
      }
    });

    // 2) newShipment - do dedupe + parsing + insert
    socketService.on('newShipment', (payload) {
      try {
        // Build stable key: prefer explicit shipment id or orderId; fallback to payload string
        String key;
        if (payload is Map &&
            (payload['id'] != null || payload['shipmentId'] != null)) {
          key = (payload['id'] ?? payload['shipmentId']).toString();
        } else if (payload is Map && payload['orderId'] != null) {
          key = payload['orderId'].toString();
        } else {
          key = payload.toString();
        }

        // dedupe window
        const dedupWindow = Duration(seconds: 30);
        final now = DateTime.now();
        final last = _recentShipments[key];
        if (last != null && now.difference(last) < dedupWindow) {
          debugPrint(
            'DriverOrderSocket: skipping duplicate newShipment key=$key',
          );
          return;
        }
        _recentShipments[key] = now;
        // cleanup old entries
        _recentShipments.removeWhere(
          (_, dt) => dt.isBefore(now.subtract(const Duration(minutes: 5))),
        );

        final newOrder = OrderModel.fromJson(
          Map<String, dynamic>.from(payload),
        );

        // Only add if order is available (not taken/completed)
        if (!_isAvailableOrder(newOrder.status.value)) {
          debugPrint(
            'DriverOrderSocket: ignoring newShipment id=${newOrder.id} because status is ${newOrder.status.value}',
          );
          return;
        }

        if (!orders.any((o) => o.id == newOrder.id)) {
          orders.insert(0, newOrder);
        }
        debugPrint('DriverOrderSocket: newShipment parsed id=${newOrder.id}');
      } catch (e) {
        debugPrint('DriverOrderSocket: error parsing newShipment: $e');
      }
    });

    // 3) shipment_status - update/remove orders
    socketService.on('shipment_status', (payload) {
      try {
        final String shipmentId = payload['shipmentId'].toString();
        final String status = payload['status'].toString().toLowerCase().replaceAll('_', '');

        debugPrint('DriverOrderSocket: shipment_status received - id=$shipmentId, status=$status');

        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          // Remove if order is taken/completed (not available anymore)
          final takenStatuses = [
            'accepted', 'assigned', 'pickedup', 'intransit', 
            'delivered', 'rejected', 'cancelled', 'completed'
          ];
          if (takenStatuses.contains(status)) {
            orders.removeAt(idx);
            debugPrint(
              'DriverOrderSocket: removed order $shipmentId - status: $status (taken/completed)',
            );
          }
        } else {
          debugPrint(
            'DriverOrderSocket: shipment_status for id=$shipmentId not in list, status=$status',
          );
        }
      } catch (e) {
        debugPrint('DriverOrderSocket: error handling shipment_status: $e');
      }
    });
    
    // 4) shipmentTaken - when another driver accepts
    socketService.on('shipmentTaken', (payload) {
      try {
        final String shipmentId = (payload['shipmentId'] ?? payload['id']).toString();
        debugPrint('DriverOrderSocket: shipmentTaken received - id=$shipmentId');
        
        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          orders.removeAt(idx);
          debugPrint('DriverOrderSocket: removed taken order $shipmentId');
        }
      } catch (e) {
        debugPrint('DriverOrderSocket: error handling shipmentTaken: $e');
      }
    });

    // socketService.on('locationUpdate', (payload) {
    //   debugPrint('DriverOrderSocket: locationUpdate received: $payload');
    //   try {
    //     Map<String, dynamic> data;
    //     if (payload is Map) {
    //       data = Map<String, dynamic>.from(payload);
    //     } else {
    //       debugPrint(
    //         'DriverOrderSocket: locationUpdate payload is not a Map, ignoring',
    //       );
    //       return;
    //     }
    //
    //     final lat = (data['lat'] ?? data['latitude']) as num?;
    //     final lng = (data['lng'] ?? data['longitude'] ?? data['lon']) as num?;
    //
    //     if (lat != null && lng != null) {
    //       final location = LatLng(lat.toDouble(), lng.toDouble());
    //
    //       // Update driver tracking controller if it exists
    //       try {
    //         final trackingController = Get.find<ShipmentTrackingController>();
    //         final driver = trackingController.driver.value;
    //         if (driver != null) {
    //           // Update driver's position directly
    //           driver.lat = location.latitude;
    //           driver.lng = location.longitude;
    //           trackingController.driver.refresh();
    //           debugPrint(
    //             'DriverOrderSocket: Updated driver position to $location',
    //           );
    //         } else {
    //           debugPrint(
    //             'DriverOrderSocket: ShipmentTrackingController exists but no driver is set',
    //           );
    //         }
    //       } catch (e) {
    //         debugPrint(
    //           'DriverOrderSocket: ShipmentTrackingController not found or error: $e',
    //         );
    //       }
    //
    //       // Also update LocationController if available
    //       try {
    //         final locationController = Get.find<LocationController>();
    //         locationController.currentPosition.value = location;
    //         debugPrint(
    //           'DriverOrderSocket: Updated LocationController position to $location',
    //         );
    //       } catch (e) {
    //         debugPrint(
    //           'DriverOrderSocket: LocationController not found, skipping update: $e',
    //         );
    //       }
    //     } else {
    //       debugPrint(
    //         'DriverOrderSocket: Invalid locationUpdate payload - missing lat/lng. Data: $data',
    //       );
    //     }
    //   } catch (e) {
    //     debugPrint('DriverOrderSocket: Error handling locationUpdate: $e');
    //   }
    // });

    // Optional: server-side error events
    socketService.on('error', (data) {
      debugPrint('DriverOrderSocket: socket error event: $data');
    });
  }

  /// Stop listening: remove all listeners we've added and clear orders
  void stop() {
    try {
      socketService.off('existingShipments');
      socketService.off('newShipment');
      socketService.off('shipment_status');
      socketService.off('shipmentTaken');
      socketService.off('locationUpdate');
      socketService.off('error');
    } catch (e) {
      debugPrint('DriverOrderSocket.stop: error while off(): $e');
    }

    orders.clear();
    _recentShipments.clear();

    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  /// Convenience wrappers to emit events via underlying socketService
  void acceptOrder(OrderModel order) {
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) socketService.emit('accept_order', {'orderId': id});
    order.status.value = OrderStatus.Accepted;
  }

  void rejectOrder(OrderModel order) {
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) socketService.emit('reject_order', {'orderId': id});
    order.status.value = OrderStatus.Declined;
  }
  
  /// Check if order is available for drivers to accept
  /// Only pending/awaiting orders should show in the list
  bool _isAvailableOrder(OrderStatus status) {
    final unavailableStatuses = [
      OrderStatus.Accepted,
      OrderStatus.Assigned,
      OrderStatus.PickedUp,
      OrderStatus.InTransit,
      OrderStatus.Delivered,
      OrderStatus.Declined,
      OrderStatus.Cancelled,
    ];
    return !unavailableStatuses.contains(status);
  }
}
