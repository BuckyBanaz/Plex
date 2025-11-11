// services/domain/service/socket/socket_service.dart

import 'dart:async';
import 'package:get/get.dart'; // <-- RxList ke liye import
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  IO.Socket? _socket;

  // Streams taaki controller inko sun sake
  final _newShipmentController = StreamController<dynamic>.broadcast();
  // final _existingShipmentsController = StreamController<List<dynamic>>.broadcast(); // <-- HATA DIYA
  final _shipmentStatusController = StreamController<dynamic>.broadcast();

  // === CHANGE START: RxList use karo cache karne ke liye ===
  final RxList<dynamic> existingShipments = <dynamic>[].obs;
  // === CHANGE END ===

  // Public streams
  Stream<dynamic> get newShipmentStream => _newShipmentController.stream;
  // Stream<List<dynamic>> get existingShipmentsStream => _existingShipmentsController.stream; // <-- HATA DIYA
  Stream<dynamic> get shipmentStatusStream => _shipmentStatusController.stream;

  // IMPORTANT: Yahaan apna server IP aur Port daalo
  static const String _serverUrl = 'http://p2dev10.in:3000';

  Future<SocketService> init() async {
    print('SocketService init...');
    _initSocket();
    return this;
  }

  void _initSocket() {
    // Apne DatabaseService se auth token lo
    // Main assume kar raha hu ki 'db.token' mein token hai
    final db = Get.find<DatabaseService>();
    final token = db.accessToken ?? ''; // Ya jahaan bhi tumne token save kiya hai

    if (token == null || token.isEmpty) {
      print('Socket Error: Auth token is missing. Cannot connect.');
      return;
    }

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Server config se match
          .setPath('/socket.io/') // Server config se match
          .disableAutoConnect()
          .setQuery({'token': token}) // Auth token yahaan bhej rahe hain
          .build(),
    );

    _socket!.connect();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      print('✅ Socket connected: ${_socket!.id}');
      // Driver ko ready state bhej sakte ho (optional)
      _socket!
          .emit('driver_ready', {'driverId': Get.find<DatabaseService>().driver?.id});
    });

    _socket!.onDisconnect((_) => print('🔌 Socket disconnected'));
    _socket!.onError((data) => print('❌ Socket error: $data'));

    // Backend se events suno

    // 1. Naya order/shipment
    _socket!.on('newShipment', (data) {
      print('🔥 Socket: Received newShipment');
      _newShipmentController.add(data);
    });

    // 2. Connection par existing orders ki list
    _socket!.on('existingShipments', (data) {
      print('📦 Socket: Received existingShipments');
      // === CHANGE START: Stream ki jagah RxList ko update karo ===
      // _existingShipmentsController.add(List<dynamic>.from(data));
      existingShipments.assignAll(List<dynamic>.from(data));
      // === CHANGE END ===
    });

    // 3. Status updates (jab koi order accept/reject ho)
    _socket!.on('shipment_status', (data) {
      print('🔄 Socket: Received shipment_status');
      _shipmentStatusController.add(data);
    });

    // 4. Server se error
    _socket!.on('error', (data) {
      print('❌ Socket Server Error: ${data['message']}');
    });
  }

  // Events jo Flutter app se backend ko bhejenge
  void acceptOrder(int orderId) {
    _socket?.emit('accept_order', {'orderId': orderId});
  }

  void rejectOrder(int orderId) {
    _socket?.emit('reject_order', {'orderId': orderId});
  }

  void updateLocation(double lat, double lng) {
    _socket?.emit('locationUpdate', {'lat': lat, 'lng': lng});
  }

  // Service close hone par streams band karo
  @override
  void onClose() {
    _newShipmentController.close();
    // _existingShipmentsController.close(); // <-- HATA DIYA
    _shipmentStatusController.close();
    _socket?.dispose();
    super.onClose();
  }
}