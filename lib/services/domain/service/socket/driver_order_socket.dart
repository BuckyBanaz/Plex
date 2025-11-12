// services/domain/service/socket/driver_order_socket.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import '../../../../models/driver_order_model.dart';
import 'socket_service.dart';


/// This class bridges SocketService -> OrderModel parsing and exposes
/// a driver-specific reactive list and streams.
class DriverOrderSocket {
  final SocketService socketService = Get.find<SocketService>();

  // Reactive orders list exposed to controllers
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  // Expose the raw newShipment stream for on-demand parsing
  StreamSubscription? _newShipmentSub;
  StreamSubscription? _shipmentStatusSub;

  DriverOrderSocket();

  /// Start listening to low-level socket streams and populate `orders`.
  /// This does NOT connect socketService itself; ensure SocketService.connect(token) already called.
  void start() {
    // Cancel if already bound
    _newShipmentSub?.cancel();
    _shipmentStatusSub?.cancel();

    // 1. Listen to existing cached shipments (immediate snapshot)
    try {
      if (socketService.existingShipments.isNotEmpty) {
        final cached = socketService.existingShipments.toList();
        final parsed = cached.map((j) => OrderModel.fromJson(Map<String, dynamic>.from(j))).toList();
        orders.assignAll(parsed);
        debugPrint('DriverOrderSocket: loaded ${parsed.length} cached orders');
      }
    } catch (e) {
      debugPrint('DriverOrderSocket: error loading cached orders: $e');
    }

    // 2. Subscribe to future existingShipments changes (RxList) -> update orders
    socketService.existingShipments.listen((list) {
      try {
        final parsed = list.map((j) => OrderModel.fromJson(Map<String, dynamic>.from(j))).toList();
        orders.assignAll(parsed);
        debugPrint('DriverOrderSocket: existingShipments stream updated (${parsed.length})');
      } catch (e) {
        debugPrint('DriverOrderSocket: parse error existingShipments listen: $e');
      }
    });

    // 3. Subscribe to newShipment event
    _newShipmentSub = socketService.newShipmentStream.listen((payload) {
      try {
        final newOrder = OrderModel.fromJson(Map<String, dynamic>.from(payload));
        // Insert if not present
        if (!orders.any((o) => o.id == newOrder.id)) {
          orders.insert(0, newOrder);
        }
        debugPrint('DriverOrderSocket: newShipment parsed id=${newOrder.id}');
      } catch (e) {
        debugPrint('DriverOrderSocket: error parsing newShipment: $e');
      }
    });

    // 4. Listen to status updates and mutate orders accordingly
    _shipmentStatusSub = socketService.shipmentStatusStream.listen((payload) {
      try {
        final String shipmentId = payload['shipmentId'].toString();
        final String status = payload['status'].toString();

        final idx = orders.indexWhere((o) => o.id == shipmentId);
        if (idx != -1) {
          // If status indicates removal, remove
          if (status == 'in_transit' || status == 'rejected' || status == 'cancelled') {
            orders.removeAt(idx);
            debugPrint('DriverOrderSocket: removed order $shipmentId due to status $status');
          } else {
            // Optionally update order.status if server sends it
            try {
              orders[idx].status.value = OrderModel.parseStatus(status);
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint('DriverOrderSocket: error handling shipment_status: $e');
      }
    });
  }

  /// Stop listening to socket streams (but does not disconnect socketService).
  void stop() {
    _newShipmentSub?.cancel();
    _newShipmentSub = null;
    _shipmentStatusSub?.cancel();
    _shipmentStatusSub = null;
    orders.clear();
  }

  /// Convenience wrappers to emit events via underlying socket
  void acceptOrder(OrderModel order) {
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) socketService.acceptOrder(id);
    order.status.value = OrderStatus.Accepted;
  }

  void rejectOrder(OrderModel order) {
    final id = int.tryParse(order.id) ?? 0;
    if (id > 0) socketService.rejectOrder(id);
    order.status.value = OrderStatus.Declined;
  }
}
