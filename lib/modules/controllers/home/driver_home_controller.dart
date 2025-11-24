// controllers/home/driver_home_controller.dart
import 'dart:async';
import 'package:flutter/material.dart' show Center, CircularProgressIndicator, Colors, debugPrint;
import 'package:get/get.dart';
import 'package:plex_user/services/domain/service/socket/socket_service.dart';
import 'package:plex_user/services/domain/service/socket/driver_order_socket.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import '../../../common/loading/loading.dart';
import '../../../models/driver_order_model.dart';
import '../../../models/driver_user_model.dart';
import '../../../routes/appRoutes.dart';
import '../../../screens/driver/home/components/new_order_sheet.dart';
import '../../../services/domain/repository/repository_imports.dart';
import '../../../common/Toast/toast.dart';

class DriverHomeController extends GetxController {
  final DatabaseService db = Get.find<DatabaseService>();
  final UserRepository userRepo = UserRepository();

  // Socket low-level service + driver specific socket handler
  final SocketService socketService = Get.find<SocketService>();
  final DriverOrderSocket driverOrderSocket = Get.put(DriverOrderSocket());

  final Rx<DriverUserModel?> currentDriver = Rx<DriverUserModel?>(null);
  final Rx<bool> isLoading = false.obs;

  // Online status for driver (bound to UI). Default false to avoid accidental connect.
  final RxBool isOnline = false.obs;

  // Orders exposed from driverOrderSocket
  RxList<OrderModel> get orders => driverOrderSocket.orders;

  // UI-level handler references so we can remove them later
  void Function(dynamic)? _onNewShipmentHandler;
  void Function(dynamic)? _onSocketErrorHandler;

  // Subscriptions if you want to react to new orders separately (not used for socket raw listening)
  StreamSubscription? _newOrderSub;

  // Some sample recent history for UI (you already had this)
  final RxList<Map<String, String>> recentHistory = <Map<String, String>>[
    {
      'name': 'Akhil Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'A',
    },
    {
      'name': 'Vipin Jain',
      'time': 'Today at 09:30 AM',
      'amount': '200',
      'initial': 'V',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },
    // ... keep rest as needed
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDriverData();

    // Setup handler references (so we can off() the same instances)
    _onNewShipmentHandler = (dynamic payload) {
      try {
        final newOrder = OrderModel.fromJson(Map<String, dynamic>.from(payload));
        // show bottom sheet (if none open)
        if (Get.isBottomSheetOpen != true) {
          showNewOrderSheet(newOrder);
        } else {
          debugPrint('DriverHomeController: bottom sheet already open; skipping newShipment sheet');
        }
      } catch (e) {
        debugPrint('DriverHomeController: error parsing newShipment payload: $e');
      }
    };

    _onSocketErrorHandler = (dynamic data) {
      debugPrint('DriverHomeController: socket error event: $data');
    };

    // React to isOnline changes: when true -> connect & start, when false -> stop & disconnect
    ever<bool>(isOnline, (online) async {
      debugPrint('DriverHomeController: isOnline changed -> $online');

      if (online == true) {
        // connect socket only when online
        final token = db.accessToken ?? '';
        final driver = currentDriver.value;
        if (token.isEmpty || driver == null) {
          debugPrint('DriverHomeController: cannot connect - missing token or driver');
          isOnline.value = false; // revert
          return;
        }

        // Connect low-level socket
        socketService.connect(token, driver.id);

        // Start driver-specific listeners (parsing & populating orders)
        driverOrderSocket.start();

        // Also attach controller-level socket listeners (for showing bottom sheet)
        try {
          socketService.on('newShipment', _onNewShipmentHandler!);
          socketService.on('error', _onSocketErrorHandler!);
        } catch (e) {
          debugPrint('DriverHomeController: error attaching socket listeners: $e');
        }
      } else {
        // stop listening and disconnect
        try {
          if (_onNewShipmentHandler != null) socketService.off('newShipment', _onNewShipmentHandler);
          if (_onSocketErrorHandler != null) socketService.off('error', _onSocketErrorHandler);
        } catch (e) {
          debugPrint('DriverHomeController: error detaching socket listeners: $e');
        }

        // Stop high-level socket handlers and clear local orders
        driverOrderSocket.stop();

        // Disconnect low-level socket
        socketService.disconnect();
      }
    });


  }

  Future<void> _loadDriverData() async {
    try {
      isLoading.value = true;
      final driverData = db.driver;
      if (driverData != null) {
        currentDriver.value = driverData;
      }
    } catch (e) {
      debugPrint("Failed to load driver data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void showNewOrderSheet(OrderModel order) {
    Get.bottomSheet(
      NewOrderSheet(orderData: order),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  /// Accept order flow (uses repository; optimistic UI update + rollback on failure).
  void acceptOrder(OrderModel order) async {
    bool loaderShown = false;

    try {
      // show loader
      if (Get.isDialogOpen == false) {
        Get.dialog(
          Center(child: CircularProgressIndicator(color: Colors.orange)),
          barrierDismissible: false,
        );
        loaderShown = true;
      }

      // close bottom sheet if any
      if (Get.isBottomSheetOpen == true) Get.back();

      // optimistic in-memory update
      try {
        order.status.value = OrderStatus.Assigned;
      } catch (_) {}

      final ShipmentRepository repo = Get.find<ShipmentRepository>();
      final result = await repo.acceptShipment(
        shipmentId: int.tryParse(order.id) ?? 0,
        order: order,
      );

      debugPrint('ACCEPT RESULT FULL: $result');

      final int? statusCode = result['statusCode'] is int ? result['statusCode'] as int : null;
      final String message = (result['message'] ?? '').toString();
      final String errorStr = (result['error'] ?? '').toString();
      final String rawStr = (result['raw'] != null) ? result['raw'].toString() : '';
      final String probe = '${message} ${errorStr} ${rawStr}'.toLowerCase();

      // failure branch
      if (result['success'] != true) {
        // rollback in-memory
        try {
          order.status.value = OrderStatus.Pending;
        } catch (_) {}

        // close loader only (not any other dialogs)
        if (loaderShown && Get.isDialogOpen == true) {
          Get.back();
          loaderShown = false;
        }

        final bool isTaken = statusCode == 409 ||
            probe.contains('already taken') ||
            probe.contains('shipment already taken') ||
            probe.contains('not found') ||
            probe.contains('taken') ||
            probe.contains('conflict');

        if (isTaken) {
          Get.defaultDialog(
            title: 'Order taken',
            middleText: 'Shipment already taken or not found. This order is not available.',
            textConfirm: 'OK',
            onConfirm: () => Get.back(),
          );
        } else {
          showToast(message: 'Failed to accept order');
          debugPrint('Accept API error: ${result['error'] ?? result['message']}');
        }
        return;
      }

      // success path
      final OrderModel? updated = result['shipment'] is OrderModel ? result['shipment'] as OrderModel : null;
      final OrderModel finalOrder = updated ?? order;

      try {
        await db.putDriverCurrentOrder(finalOrder);
        debugPrint('Saved driver current order (id: ${finalOrder.id})');
      } catch (e) {
        debugPrint('Failed to save current order: $e');
      }

      // close loader only
      if (loaderShown && Get.isDialogOpen == true) {
        Get.back();
        loaderShown = false;
      }

      // navigate to tracking
      final Map<String, dynamic> args = {
        'shipment': {
          'id': finalOrder.id,
          'orderId': finalOrder.orderId,
          'pickup': {
            'name': finalOrder.pickup.name,
            'phone': finalOrder.pickup.phone,
            'address': finalOrder.pickup.address,
            'latitude': finalOrder.pickup.latitude,
            'longitude': finalOrder.pickup.longitude,
          },
          'dropoff': {
            'name': finalOrder.dropoff.name,
            'phone': finalOrder.dropoff.phone,
            'address': finalOrder.dropoff.address,
            'latitude': finalOrder.dropoff.latitude,
            'longitude': finalOrder.dropoff.longitude,
          },
          'invoiceNumber': finalOrder.invoiceNumber,
          'estimatedCost': finalOrder.estimatedCost,
          'driverId': finalOrder.driverId,
        }
      };
      Get.toNamed(AppRoutes.driverOrderTracking, arguments: args);
    } catch (e, st) {
      debugPrint('Error accepting order: $e\n$st');
      try {
        order.status.value = OrderStatus.Pending;
      } catch (_) {}
      if (loaderShown && Get.isDialogOpen == true) {
        Get.back();
        loaderShown = false;
      }
      showToast(message: 'Something went wrong');
    } finally {
      if (loaderShown && Get.isDialogOpen == true) {
        Get.back();
        loaderShown = false;
      }
    }
  }

  void rejectOrder(OrderModel order) {
    driverOrderSocket.rejectOrder(order);
    if (Get.isBottomSheetOpen == true) Get.back();
  }

  /// Toggle online status: flips local state and attempts to update backend.
  Future<void> toggleOnlineStatus() async {
    // Flip local state immediately for snappy UI; the `ever` will react and connect/disconnect sockets.
    isOnline.value = !isOnline.value;

    try {
      await userRepo.updateStatus(isOnline.value);
      debugPrint("Updated driver online status to: ${isOnline.value}");
    } catch (e) {
      // Revert on failure
      isOnline.value = !isOnline.value;
      debugPrint("Error updating driver status: $e");
      showToast(message: "Failed to update online status");
    }
  }

  @override
  void onClose() {
    // detach socket handlers
    try {
      if (_onNewShipmentHandler != null) socketService.off('newShipment', _onNewShipmentHandler);
      if (_onSocketErrorHandler != null) socketService.off('error', _onSocketErrorHandler);
    } catch (e) {
      debugPrint('DriverHomeController.onClose: error detaching listeners: $e');
    }

    _newOrderSub?.cancel();
    driverOrderSocket.stop();
    socketService.disconnect();
    super.onClose();
  }
}
