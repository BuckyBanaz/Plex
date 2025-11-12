// services/domain/service/socket/socket_service.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;

  // Streams
  final _newShipmentController = StreamController<dynamic>.broadcast();
  final _shipmentStatusController = StreamController<dynamic>.broadcast();

  // Cache for existing shipments (kept as RxList for easy reactive usage)
  final RxList<dynamic> existingShipments = <dynamic>[].obs;

  Stream<dynamic> get newShipmentStream => _newShipmentController.stream;
  Stream<dynamic> get shipmentStatusStream => _shipmentStatusController.stream;

  // Server URL (adjust if needed)
  static const String _serverUrl = 'http://p2dev10.in:3000';

  SocketService();

  /// Connect socket (requires auth token). This DOES NOT call init automatically.
  /// Call connect(token) when you want to establish socket (e.g., when driver goes online).
  void connect(String token) {
    if (token.isEmpty) {
      debugPrint('SocketService.connect: token empty, aborting');
      return;
    }

    // Prevent multiple connects
    if (_socket != null && _socket!.connected) {
      debugPrint('SocketService: socket already connected');
      return;
    }

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io/')
          .disableAutoConnect()
          .setQuery({'token': token})
          .build(),
    );

    _socket!.connect();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected (${_socket!.id})');
      final db = Get.find<DatabaseService>();
      _socket!.emit('driver_ready', {'driverId': db.driver?.id});
    });

    _socket!.onDisconnect((_) => debugPrint('🔌 Socket disconnected'));
    _socket!.onError((data) => debugPrint('❌ Socket error: $data'));

    // New shipment
    _socket!.on('newShipment', (data) {
      debugPrint('🔥 SocketService: newShipment received');
      _newShipmentController.add(data);
    });

    // existing shipments list on connect or explicit emit
    _socket!.on('existingShipments', (data) {
      debugPrint('📦 SocketService: existingShipments received (${(data as List?)?.length ?? 0})');
      try {
        final list = List<dynamic>.from(data ?? []);
        existingShipments.assignAll(list);
      } catch (e) {
        debugPrint('SocketService: failed parsing existingShipments: $e');
      }
    });

    // status updates
    _socket!.on('shipment_status', (data) {
      debugPrint('🔄 SocketService: shipment_status received');
      _shipmentStatusController.add(data);
    });

    // server side error messages
    _socket!.on('error', (data) {
      try {
        debugPrint('❌ SocketServerError: ${data['message']}');
      } catch (_) {
        debugPrint('❌ SocketServerError: $data');
      }
    });
  }

  /// Disconnect and cleanup
  void disconnect() {
    try {
      debugPrint('SocketService: disconnecting...');
      _socket?.disconnect();
      _socket?.dispose();
    } catch (e) {
      debugPrint('SocketService.disconnect error: $e');
    }
    _socket = null;
    existingShipments.clear();
  }

  // Outgoing events
  void acceptOrder(int orderId) {
    _socket?.emit('accept_order', {'orderId': orderId});
  }

  void rejectOrder(int orderId) {
    _socket?.emit('reject_order', {'orderId': orderId});
  }

  void updateLocation(double lat, double lng) {
    _socket?.emit('locationUpdate', {'lat': lat, 'lng': lng});
  }

  @override
  void onClose() {
    _newShipmentController.close();
    _shipmentStatusController.close();
    disconnect();
    super.onClose();
  }
}
