// controllers/driver_home_controller.dart
import 'dart:async';
import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:get/get.dart';
import 'package:plex_user/services/domain/service/socket/socket_service.dart';
import 'package:plex_user/services/domain/service/socket/driver_order_socket.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import '../../../models/driver_order_model.dart';
import '../../../models/driver_user_model.dart';
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
    }, {
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
    }, {
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
    }, {
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
    }, {
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
        socketService.connect(token);         // establish low-level socket
        driverOrderSocket.start();            // bind streams & populate orders

        // Optionally listen to newShipment to show bottom sheet here
        _newOrderSub?.cancel();

        _newOrderSub = socketService.newShipmentStream.listen((payload) {
          try {
            final newOrder = OrderModel.fromJson(Map<String, dynamic>.from(payload));
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
        driverOrderSocket.stop();             // stop internal listeners and clear orders
        socketService.disconnect();           // disconnect socket
      }
    });

    // Initial behaviour: start socket only if isOnline true
    if (isOnline.value == true) {
      final token = db.accessToken ?? '';
      if (token.isNotEmpty) {
        socketService.connect(token);
        driverOrderSocket.start();
        _newOrderSub = socketService.newShipmentStream.listen((payload) {
          try {
            final newOrder = OrderModel.fromJson(Map<String, dynamic>.from(payload));
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

  void acceptOrder(OrderModel order) {
    // Use driverOrderSocket wrapper
    driverOrderSocket.acceptOrder(order);
    Get.back(); // close bottom sheet
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
