// file: lib/services/socket/user_order_socket.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/driver_order_model.dart';
import 'socket_service.dart';

class UserOrderSocket {
  final SocketService socketService = Get.find<SocketService>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxMap<String, Map<String, dynamic>> liveLocations = <String, Map<String, dynamic>>{}.obs;
  final Rx<OrderModel?> activeTrackingOrder = Rx<OrderModel?>(null);

  final List<StreamSubscription> _subs = [];

  UserOrderSocket();

  void start() {
    final sock = socketService.socket;
    if (sock == null) {
      debugPrint('UserOrderSocket.start: socket is null — call SocketService.connect(...) first');
      return;
    }

    debugPrint('UserOrderSocket: attaching listeners');

    socketService.on('shipment_status', (payload) {
      try {
        final Map p = payload is Map ? payload : Map<String, dynamic>.from(payload);
        final shipmentId = (p['shipmentId'] ?? p['orderId'] ?? p['id']).toString();
        final statusStr = (p['status'] ?? '').toString();
        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          orders[idx].status.value = OrderModel.parseStatus(statusStr);
          if (p['deliveredAt'] != null) {
            orders[idx] = OrderModel.fromJson({
              ..._safeToMap(orders[idx]),
              'deliveredAt': p['deliveredAt']
            });
          }
          orders.refresh();
        } else {
          try {
            final maybe = OrderModel.fromJson(p);
            if (maybe.userId == null || maybe.userId == socketService.currentUserId) {
              orders.insert(0, maybe);
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('UserOrderSocket: shipment_status error: $e');
      }
    });

    socketService.on('locationUpdate', (payload) {
      try {
        final Map p = payload is Map ? payload : Map<String, dynamic>.from(payload);
        final shipmentId = (p['shipmentId'] ?? p['orderId'] ?? p['id'])?.toString() ?? '';
        if (shipmentId.isEmpty) return;

        final lat = _toDouble(p['lat'] ?? p['latitude'] ?? p['latLng']?['lat']);
        final lng = _toDouble(p['lng'] ?? p['longitude'] ?? p['lon'] ?? p['latLng']?['lng']);

        if (lat == null || lng == null) return;

        liveLocations[shipmentId] = {
          'lat': lat,
          'lng': lng,
          'ts': p['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
          'raw': p,
        };

        // update orders list if present
        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          final m = _safeToMap(orders[idx]);
          m['liveLocation'] = liveLocations[shipmentId];
          orders[idx] = OrderModel.fromJson(m);
        }

        // notify listeners (controllers subscribe to liveLocations)
        liveLocations.refresh();
      } catch (e) {
        debugPrint('UserOrderSocket: locationUpdate error: $e');
      }
    });

    socketService.on('order_confirmed', (payload) {
      try {
        final Map p = payload is Map ? payload : Map<String, dynamic>.from(payload);
        final shipment = OrderModel.fromJson(p['shipment'] ?? p);
        final idx = orders.indexWhere((o) => o.id == shipment.id);
        if (idx != -1) {
          orders[idx] = shipment;
        } else {
          if (socketService.currentUserId == null || shipment.userId == null || shipment.userId == socketService.currentUserId) {
            orders.insert(0, shipment);
          }
        }
      } catch (e) {
        debugPrint('UserOrderSocket: order_confirmed error: $e');
      }
    });

    socketService.on('error', (d) => debugPrint('UserOrderSocket: socket error: $d'));
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  void startTracking(OrderModel order) {
    if (socketService.socket == null) {
      debugPrint('startTracking: socket is null, make sure to call socketService.connect(...) and userOrderSocket.start()');
      return;
    }
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) {
      socketService.emit('joinShipment', id);
      activeTrackingOrder.value = order;
    } else {
      activeTrackingOrder.value = order;
    }
  }

  void stopTracking() => activeTrackingOrder.value = null;

  Map<String, dynamic>? getLiveLocation(String shipmentId) => liveLocations[shipmentId];

  void cancelOrder(OrderModel order, {String reason = ''}) {
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) {
      socketService.emit('cancel_order', {'orderId': id, 'reason': reason});
    }
  }

  void stop() {
    try {
      socketService.off('existingShipments');
      socketService.off('newShipment');
      socketService.off('shipment_status');
      socketService.off('locationUpdate');
      socketService.off('order_confirmed');
      socketService.off('error');
    } catch (e) {
      debugPrint('UserOrderSocket.stop error: $e');
    }
    orders.clear();
    liveLocations.clear();
    activeTrackingOrder.value = null;
    for (final s in _subs) s.cancel();
    _subs.clear();
  }

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
      'driverDetails': o.driverDetails,
      'liveLocation': o.liveLocation,
    };
  }
}
