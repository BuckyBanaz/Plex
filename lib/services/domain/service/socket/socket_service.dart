import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';

import '../api/api_import.dart'; // adjust imports

class SocketService extends GetxService {
  late IO.Socket socket;
  final String namespace; // optional if your server uses namespace

  SocketService({this.namespace = ''});

  Future<SocketService> init() async {
    await Future.delayed(Duration(milliseconds: 100)); // optional small delay
    _createAndConnect();
    return this;
  }

  void _createAndConnect() {
    // get token or headers from DatabaseService or ApiService
    final db = Get.find<DatabaseService>();
    final token = db.apiKey ?? db.accessToken!; // adjust based on your DB service API

    final api = Get.find<ApiService>();
    final uri = api.serverUrl; // e.g. "http://35.154.158.173:3000"

    final url = namespace.isNotEmpty ? '$uri/$namespace' : uri;

    socket = IO.io(
      url,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        // send token in headers
        'extraHeaders': {'token': token ?? ''},
        // if using query param auth instead:
        // 'query': {'token': token ?? ''},
      },
    );

    // events
    socket.onConnect((_) {
      print('[Socket] connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('[Socket] disconnected');
    });

    socket.onConnectError((err) {
      print('[Socket] connect error: $err');
    });

    socket.onError((err) {
      print('[Socket] error: $err');
    });

    // example server event listener
    socket.on('message', (data) {
      print('[Socket] message: $data');
      // you can broadcast to Getx controllers or update Rx values here
    });

    // auto reconnect options handled by socket_io_client by default
    socket.connect();
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    } else {
      print('[Socket] emit failed — not connected');
    }
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void off(String event) {
    socket.off(event);
  }

  bool get isConnected => socket.connected;

  Future<void> disconnect() async {
    try {
      socket.disconnect();
      socket.dispose();
    } catch (e) {
      print('[Socket] disconnect error: $e');
    }
  }
}
