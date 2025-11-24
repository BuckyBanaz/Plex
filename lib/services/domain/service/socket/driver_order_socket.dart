// services/domain/service/socket/driver_order_socket.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
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
      debugPrint('DriverOrderSocket.start: socket is null — make sure SocketService.connect was called');
      return;
    }

    debugPrint('DriverOrderSocket: setting up listeners on raw socket');

    // 1) existingShipments - keep the central cache in socketService and also parse into orders
    socketService.on('existingShipments', (data) {
      debugPrint('DriverOrderSocket: existingShipments received (${(data as List?)?.length ?? 0})');
      try {
        final list = List<dynamic>.from(data ?? []);
        // update central cache (optional)
        socketService.existingShipments.assignAll(list);

        // parse and filter
        final parsed = list
            .map((j) => OrderModel.fromJson(Map<String, dynamic>.from(j)))
            .where((o) => o.status.value != OrderStatus.InTransit)
            .toList();
        orders.assignAll(parsed);
        debugPrint('DriverOrderSocket: parsed ${parsed.length} cached orders (filtered InTransit)');
      } catch (e) {
        debugPrint('DriverOrderSocket: error parsing existingShipments: $e');
      }
    });

    // 2) newShipment - do dedupe + parsing + insert
    socketService.on('newShipment', (payload) {
      try {
        // Build stable key: prefer explicit shipment id or orderId; fallback to payload string
        String key;
        if (payload is Map && (payload['id'] != null || payload['shipmentId'] != null)) {
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
          debugPrint('DriverOrderSocket: skipping duplicate newShipment key=$key');
          return;
        }
        _recentShipments[key] = now;
        // cleanup old entries
        _recentShipments.removeWhere((_, dt) => dt.isBefore(now.subtract(const Duration(minutes: 5))));

        final newOrder = OrderModel.fromJson(Map<String, dynamic>.from(payload));

        if (newOrder.status.value == OrderStatus.InTransit) {
          debugPrint('DriverOrderSocket: ignoring newShipment id=${newOrder.id} because status is InTransit');
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
        final String status = payload['status'].toString();

        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          if (status == 'in_transit' || status == 'rejected' || status == 'cancelled') {
            orders.removeAt(idx);
            debugPrint('DriverOrderSocket: removed order $shipmentId due to status $status');
          } else {
            try {
              orders[idx].status.value = OrderModel.parseStatus(status);
            } catch (_) {}
          }
        } else {
          debugPrint('DriverOrderSocket: shipment_status for unknown id=$shipmentId, status=$status');
        }
      } catch (e) {
        debugPrint('DriverOrderSocket: error handling shipment_status: $e');
      }
    });

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
}
