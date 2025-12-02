import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  IO.Socket? _socket;

  // Lightweight reactive cache for existing shipments (can be used by other services)
  final RxList<dynamic> existingShipments = <dynamic>[].obs;

  // Server URL (adjust if needed)
  static const String _serverUrl = 'http://p2dev10.in:3000';

  // Prevent registering listeners multiple times at Service-level
  bool _connected = false;

  // store token/userId for other services to read (fixes lack of handshake getter)
  String? _currentToken;
  int? _currentUserId;

  SocketService();

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// expose current user id/token
  int? get currentUserId => _currentUserId;
  String? get currentToken => _currentToken;

  /// Connect socket (requires auth token). Keeps connection simple.
  void connect(String token, int userId) {
    if (token.isEmpty) {
      debugPrint('SocketService.connect: token empty, aborting');
      return;
    }

    // store for other consumers
    _currentToken = token;
    _currentUserId = userId;

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

    _socket!.onConnect((_) {
      _connected = true;
      debugPrint('✅ SocketService: connected (${_socket!.id})');
      // keep only basic emit on connect (optional)
      try {
        final db = Get.find<DatabaseService>(); // replace with actual DatabaseService type if you want
        // prefer driver.id or fallback to stored userId for emit
        final driverId = db?.driver?.id ?? _currentUserId;
        _socket!.emit('driver_ready', {'driverId': driverId});
      } catch (e) {
        debugPrint('SocketService.onConnect: error finding DatabaseService: $e');
      }
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      debugPrint('🔌 SocketService: disconnected');
    });

    _socket!.onError((data) => debugPrint('❌ SocketService: error: $data'));
  }

  /// Generic helper to listen for events (used by higher-level sockets)
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler as void Function(dynamic)?);
    } else {
      _socket?.off(event);
    }
  }

  /// Emit event through socket
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
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
    _currentToken = null;
    _currentUserId = null;
    _connected = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
