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

  // Prevent registering listeners multiple times
  bool _listenersSetup = false;

  // Dedup map: shipmentId (or key) -> last seen time
  final Map<String, DateTime> _recentShipments = {};

  /// Connect socket (requires auth token).
  void connect(String token, int userId) {
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
          .setQuery({'token': token, 'userId': userId})
          .build(),
    );

    _socket!.connect();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    if (_socket == null) return;
    if (_listenersSetup) {
      debugPrint('SocketService: listeners already setup — skipping.');
      return;
    }
    _listenersSetup = true;

    int _newShipmentCount = 0;

    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected (${_socket!.id})');
      try {
        final db = Get.find<DatabaseService>();
        _socket!.emit('driver_ready', {'driverId': db.driver?.id});
      } catch (e) {
        debugPrint('SocketService.onConnect: error finding DatabaseService: $e');
      }
    });

    _socket!.onDisconnect((_) => debugPrint('🔌 Socket disconnected'));
    _socket!.onError((data) => debugPrint('❌ Socket error: $data'));

    // New shipment with client-side deduplication
    _socket!.on('newShipment', (data) {
      try {
        _newShipmentCount++;

        // Build stable key: prefer explicit shipment id or orderId; fallback to payload string
        String key;
        try {
          if (data is Map && (data['id'] != null || data['shipmentId'] != null)) {
            key = (data['id'] ?? data['shipmentId']).toString();
          } else if (data is Map && data['orderId'] != null) {
            key = data['orderId'].toString();
          } else {
            key = data.toString();
          }
        } catch (_) {
          key = data.toString();
        }

        // Deduplication window
        const dedupWindow = Duration(seconds: 30);
        final now = DateTime.now();
        final last = _recentShipments[key];
        if (last != null && now.difference(last) < dedupWindow) {
          // debugPrint('SocketService: skipping duplicate newShipment (key=$key) count=$_newShipmentCount');
          return;
        }

        // record last seen
        _recentShipments[key] = now;

        // cleanup older entries occasionally
        _recentShipments.removeWhere((_, dt) => dt.isBefore(now.subtract(const Duration(minutes: 5))));

        debugPrint('🔥 SocketService: newShipment received (count=$_newShipmentCount, key=$key)');
        _newShipmentController.add(data);
      } catch (e) {
        debugPrint('SocketService.newShipment handler error: $e');
        // fallback: still push raw payload so app can handle gracefully
        try {
          _newShipmentController.add(data);
        } catch (_) {}
      }
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
    _recentShipments.clear();
    _listenersSetup = false;
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
