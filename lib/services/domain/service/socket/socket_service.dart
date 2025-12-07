// file: lib/services/socket/socket_service.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  IO.Socket? _socket;

  final RxList<dynamic> existingShipments = <dynamic>[].obs;

  static const String _serverUrl = 'http://p2dev10.in:3000';

  bool _connected = false;
  String? _currentToken;
  int? _currentUserId;

  SocketService();

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  int? get currentUserId => _currentUserId;
  String? get currentToken => _currentToken;

  void connect(String token, int userId) {
    if (token.isEmpty) {
      debugPrint('SocketService.connect: token empty, aborting');
      return;
    }

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
      try {
        // optional notify driver ready
        _socket!.emit('driver_ready', {'driverId': _currentUserId});
      } catch (e) {
        debugPrint('SocketService.onConnect emit error: $e');
      }
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      debugPrint('🔌 SocketService: disconnected');
    });

    _socket!.onError((data) => debugPrint('❌ SocketService: error: $data'));
  }

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

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

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
