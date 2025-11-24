// file: services/socket/user_order_socket.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/driver_order_model.dart';
// <- adjust path if needed
import '../socket/socket_service.dart';

class UserOrderSocket {
  final SocketService socketService = Get.find<SocketService>();

  /// Exposed reactive state
  final RxList<OrderModel> orders = <OrderModel>[].obs; // user's orders / shipments
  final RxMap<String, Map<String, dynamic>> _liveLocations = <String, Map<String,dynamic>>{}.obs;
  final Rx<OrderModel?> activeTrackingOrder = Rx<OrderModel?>(null);

  // optional stream subs (if you create any streams)
  final List<StreamSubscription> _subs = [];

  // internal dedupe map (to avoid duplicate processing)
  final Map<String, DateTime> _recent = {};

  UserOrderSocket();

  void start() {
    final sock = socketService.socket;
    if (sock == null) {
      debugPrint('UserOrderSocket.start: socket is null — call SocketService.connect(...) first');
      return;
    }

    debugPrint('UserOrderSocket: attaching listeners');

    // 1) existingShipments (server might send list of shipments relevant to this user)
    socketService.on('existingShipments', (data) {
      debugPrint('UserOrderSocket: existingShipments received ${(data as List?)?.length ?? 0}');
      try {
        final list = List<dynamic>.from(data ?? []);
        final parsed = list.map((j) => OrderModel.fromJson(Map<String, dynamic>.from(j))).toList();
        // keep only shipments for this user (if backend sends global list)
        final userId = socketService.currentUserId?.toString();
        if (userId != null && userId.isNotEmpty) {
          orders.assignAll(parsed.where((o) => o.userId?.toString() == userId).toList());
        } else {
          orders.assignAll(parsed);
        }
      } catch (e) {
        debugPrint('UserOrderSocket: error parsing existingShipments: $e');
      }
    });

    // 2) shipment_status or shipment_update -> update single order status
    socketService.on('shipment_status', (payload) {
      try {
        final Map p = payload is Map ? payload : Map<String, dynamic>.from(payload);
        final shipmentId = (p['shipmentId'] ?? p['orderId'] ?? p['id']).toString();
        final statusStr = (p['status'] ?? '').toString();
        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          orders[idx].status.value = OrderModel.parseStatus(statusStr);
          // update deliveredAt if provided
          if (p['deliveredAt'] != null) {
            orders[idx] = OrderModel.fromJson({
              ..._safeToMap(orders[idx]),
              'deliveredAt': p['deliveredAt']
            });
          }
        } else {
          // if it's not in list, but status is active for this user, add it
          try {
            final maybe = OrderModel.fromJson(p);
            if (maybe.userId != null && maybe.userId == socketService.currentUserId) {
              orders.insert(0, maybe);
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('UserOrderSocket: error handling shipment_status: $e');
      }
    });

    // 3) newShipment or order_assigned -> could be new order for user
    socketService.on('newShipment', (payload) {
      try {
        // dedupe
        final key = payload is Map ? ((payload['id'] ?? payload['orderId'] ?? payload.toString()).toString()) : payload.toString();
        final now = DateTime.now();
        final last = _recent[key];
        if (last != null && now.difference(last).inSeconds < 10) return;
        _recent[key] = now;

        final newOrder = OrderModel.fromJson(Map<String, dynamic>.from(payload));
        // add if belongs to this user or if backend already filtered
        if (socketService.currentUserId == null || newOrder.userId == null || newOrder.userId == socketService.currentUserId) {
          orders.removeWhere((o) => o.id == newOrder.id);
          orders.insert(0, newOrder);
          debugPrint('UserOrderSocket: newShipment added id=${newOrder.id}');
        }
      } catch (e) {
        debugPrint('UserOrderSocket: error parsing newShipment: $e');
      }
    });

    // 4) location updates (live tracking) -- server might emit 'locationUpdate' with shipmentId
    socketService.on('locationUpdate', (payload) {
      try {
        final Map p = payload is Map ? payload : Map<String, dynamic>.from(payload);
        final shipmentId = (p['shipmentId'] ?? p['orderId'] ?? p['id'])?.toString() ?? '';
        if (shipmentId.isEmpty) return;

        _liveLocations[shipmentId] = {
          'lat': p['lat'] ?? p['latitude'] ?? p['lng'] ?? p['lon'],
          'lng': p['lng'] ?? p['longitude'] ?? p['lon'] ?? p['lng'],
          'ts': DateTime.now().toIso8601String(),
        };

        // if we're actively tracking this shipment, we can expose the location elsewhere
        if (activeTrackingOrder.value?.id == shipmentId) {
          _liveLocations.refresh();
        }
      } catch (e) {
        debugPrint('UserOrderSocket: error handling locationUpdate: $e');
      }
    });

    // 5) order_confirmed / order_updated events
    socketService.on('order_confirmed', (payload) {
      try {
        final Map p = payload is Map ? payload : Map<String, dynamic>.from(payload);
        final shipment = OrderModel.fromJson(p['shipment'] ?? p);
        // update or insert
        final idx = orders.indexWhere((o) => o.id == shipment.id);
        if (idx != -1) {
          orders[idx] = shipment;
        } else {
          if (socketService.currentUserId == null || shipment.userId == null || shipment.userId == socketService.currentUserId) {
            orders.insert(0, shipment);
          }
        }
      } catch (e) {
        debugPrint('UserOrderSocket: order_confirmed parse error: $e');
      }
    });

    socketService.on('error', (d) => debugPrint('UserOrderSocket: socket error: $d'));
  }

  /// Start tracking a particular shipment: joins server room and sets activeTrackingOrder
  void startTracking(OrderModel order) {
    if (socketService.socket == null) return;
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) {
      socketService.emit('joinShipment', id); // backend expects this event in your server code
      activeTrackingOrder.value = order;
    } else {
      activeTrackingOrder.value = order; // still set, but can't join room
    }
  }

  /// Stop tracking (leave UI tracking)
  void stopTracking() {
    activeTrackingOrder.value = null;
  }

  /// Get latest live location for a shipmentId (may return null)
  Map<String, dynamic>? getLiveLocation(String shipmentId) => _liveLocations[shipmentId];

  /// User actions: cancel order (emit)
  void cancelOrder(OrderModel order, {String reason = ''}) {
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) {
      socketService.emit('cancel_order', {'orderId': id, 'reason': reason});
    }
  }

  /// Clean up listeners
  void stop() {
    try {
      socketService.off('existingShipments');
      socketService.off('newShipment');
      socketService.off('shipment_status');
      socketService.off('locationUpdate');
      socketService.off('order_confirmed');
      socketService.off('error');
    } catch (e) {
      debugPrint('UserOrderSocket.stop: error while off(): $e');
    }
    orders.clear();
    _liveLocations.clear();
    activeTrackingOrder.value = null;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  // helper: convert a minimal OrderModel to Map for merging (not full fidelity)
  static Map<String, dynamic> _safeToMap(OrderModel o) {
    return {
      'id': o.id,
      'orderId': o.orderId,
      'userId': o.userId,
      'status': o.status.value.toString().split('.').last.toLowerCase(),
      'pickup': {
        'name': o.pickup.name,
        'phone': o.pickup.phone,
        'address': o.pickup.address,
        'latitude': o.pickup.latitude,
        'longitude': o.pickup.longitude,
      },
      'dropoff': {
        'name': o.dropoff.name,
        'phone': o.dropoff.phone,
        'address': o.dropoff.address,
        'latitude': o.dropoff.latitude,
        'longitude': o.dropoff.longitude,
      },
    };
  }
}
