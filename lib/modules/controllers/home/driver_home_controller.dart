// ---------- controllers/driver_home_controller.dart ----------
import 'dart:async';
import 'package:flutter/material.dart' show Colors, debugPrint, Center, CircularProgressIndicator;
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

  // Online status for driver (bound to UI)
  final RxBool isOnline = true.obs;

  // Orders exposed from driverOrderSocket
  RxList<OrderModel> get orders => driverOrderSocket.orders;

  // Subscriptions if you want to react to new orders separately
  StreamSubscription? _newOrderSub;
  StreamSubscription? _newOrderStatus;
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
      'initial': 'A',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },
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
      'initial': 'A',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },
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
      'initial': 'A',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },
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
      'initial': 'A',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },
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
      'initial': 'A',
    },
    {
      'name': 'Parikshit Verma',
      'time': 'Today at 10:30 AM',
      'amount': '200',
      'initial': 'P',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDriverData();

    // React to isOnline changes: when true -> connect & start, when false -> stop & disconnect
    ever<bool>(isOnline, (online) async {
      debugPrint('DriverHomeController: isOnline changed -> $online');
      if (online == true) {
        // connect socket only when online
        final token = db.accessToken ?? '';
        if (token.isEmpty) {
          debugPrint('No token available — cannot connect socket');
          return;
        }
        socketService.connect(
          token,
          currentDriver.value!.id,
        ); // establish low-level socket
        driverOrderSocket.start(); // bind streams & populate orders

        // Optionally listen to newShipment to show bottom sheet here
        _newOrderSub?.cancel();

        _newOrderSub = socketService.newShipmentStream.listen((payload) {
          try {
            final newOrder = OrderModel.fromJson(
              Map<String, dynamic>.from(payload),
            );
            // show bottom sheet (if none open)
            if (Get.isBottomSheetOpen != true) {
              showNewOrderSheet(newOrder);
            }
          } catch (e) {
            debugPrint('Error parsing newShipment in controller: $e');
          }
        });
      } else {
        // stop listening and disconnect
        _newOrderSub?.cancel();
        driverOrderSocket.stop(); // stop internal listeners and clear orders
        socketService.disconnect(); // disconnect socket
      }
    });

    // Initial behaviour: start socket only if isOnline true
    if (isOnline.value == true) {
      final token = db.accessToken ?? '';
      if (token.isNotEmpty) {
        socketService.connect(token, currentDriver.value!.id);
        driverOrderSocket.start();
        _newOrderSub = socketService.newShipmentStream.listen((payload) {
          try {
            final newOrder = OrderModel.fromJson(
              Map<String, dynamic>.from(payload),
            );
            if (Get.isBottomSheetOpen != true) showNewOrderSheet(newOrder);
          } catch (e) {
            debugPrint('Error parsing newShipment in init: $e');
          }
        });
      }
    }
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

  // void acceptOrder(OrderModel order) async {
  //   try {
  //     // 1) Close bottom sheet immediately for snappy UI
  //     if (Get.isBottomSheetOpen == true) Get.back();
  //
  //     // 2) Optional: optimistic UI update — mark status locally
  //     try {
  //       order.status.value = OrderStatus.Assigned;
  //       // persist if you have a DB upsert method
  //       try {
  //         if ((db as dynamic).upsertShipment != null) {
  //           await (db as dynamic).upsertShipment(order);
  //         }
  //       } catch (_) {}
  //     } catch (_) {}
  //
  //     // 3) Call repository / api to accept
  //     final ShipmentRepository repo = Get.find<ShipmentRepository>();
  //     final result = await repo.acceptShipment(
  //       shipmentId: int.tryParse(order.id) ?? 0,
  //       order: order,
  //     );
  //
  //     if (result.containsKey('error') || result['success'] != true) {
  //       // If API failed, revert and show error
  //       order.status.value = OrderStatus.Pending;
  //       showToast(message: 'Failed to accept order');
  //       debugPrint('Accept API error: ${result['error'] ?? result['message']}');
  //       return;
  //     }
  //
  //     // 4) If server returned updated shipment, prefer that
  //     final OrderModel? updated = result['shipment'] is OrderModel
  //         ? result['shipment'] as OrderModel
  //         : null;
  //     final OrderModel finalOrder = updated ?? order;
  //
  //     // 5) Navigate to Driver Order Tracking screen and pass shipment as map (safer)
  //     // Convert to a simple Map if you don't have toJson - pass minimal fields needed
  //     final Map<String, dynamic> args = {
  //       'shipment': {
  //         'id': finalOrder.id,
  //         'orderId': finalOrder.orderId,
  //         'pickup': {
  //           'name': finalOrder.pickup.name,
  //           'phone': finalOrder.pickup.phone,
  //           'address': finalOrder.pickup.address,
  //           'latitude': finalOrder.pickup.latitude,
  //           'longitude': finalOrder.pickup.longitude,
  //         },
  //         'dropoff': {
  //           'name': finalOrder.dropoff.name,
  //           'phone': finalOrder.dropoff.phone,
  //           'address': finalOrder.dropoff.address,
  //           'latitude': finalOrder.dropoff.latitude,
  //           'longitude': finalOrder.dropoff.longitude,
  //         },
  //         'invoiceNumber': finalOrder.invoiceNumber,
  //         'estimatedCost': finalOrder.estimatedCost,
  //         'driverId': finalOrder.driverId,
  //       },
  //     };
  //
  //     // navigate
  //     Get.toNamed(AppRoutes.driverOrderTracking, arguments: args);
  //   } catch (e, st) {
  //     debugPrint('Error accepting order: $e\n$st');
  //     showToast(message: 'Something went wrong while accepting order');
  //     try {
  //       order.status.value = OrderStatus.Pending;
  //     } catch (_) {}
  //   }
  // }
  void acceptOrder(OrderModel order) async {
    bool loaderShown = false;

    // show loader
    try {
      if (Get.isDialogOpen == false) {
        Get.dialog(
          Center(child: CircularProgressIndicator(color: Colors.orange)),
          barrierDismissible: false,
        );
        loaderShown = true;
      } else {
        // if some dialog is already open, still try to show loader and mark flag
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
          // pop loader dialog we opened
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
          // show user dialog (this should remain until user taps OK)
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

      // navigate
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
      // Only close loader if still open. Do NOT close other dialogs.
      if (loaderShown && Get.isDialogOpen == true) {
        Get.back();
        loaderShown = false;
      }
    }
  }


  void rejectOrder(OrderModel order) {
    driverOrderSocket.rejectOrder(order);
    Get.back(); // close bottom sheet
  }

  Future<void> toggleOnlineStatus() async {
    // Flip local state immediately for snappy UI
    isOnline.value = !isOnline.value;

    try {
      // Call repository which ensures driver-only logic
      await userRepo.updateStatus(isOnline.value);
      debugPrint("Updated driver online status to: ${isOnline.value}");
    } catch (e) {
      // Revert state on failure and show toast
      isOnline.value = !isOnline.value;
      debugPrint("Error updating driver status: $e");
      showToast(message: "Failed to update online status");
    }
  }

  @override
  void onClose() {
    _newOrderSub?.cancel();
    driverOrderSocket.stop();
    socketService.disconnect();
    super.onClose();
  }
}
