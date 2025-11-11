import 'dart:async';

import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:get/get.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/services/domain/service/api/api_import.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';

import '../../../common/Toast/toast.dart';
import '../../../models/driver_order_model.dart';
import '../../../models/driver_user_model.dart';
import '../../../screens/driver/home/components/new_order_sheet.dart';
import '../../../services/domain/repository/repository_imports.dart';
import '../../../services/domain/service/socket/socket_service.dart';

class DriverHomeController extends GetxController {

  final DatabaseService db = Get.find<DatabaseService>();
  final UserRepository userRepo = UserRepository();
  final SocketService socketService = Get.find<SocketService>(); // <-- GET KARO
  final Rx<DriverUserModel?> currentDriver = Rx<DriverUserModel?>(null);
  final Rx<bool> isLoading = false.obs;

  // Online status for driver (bound to UI)
  final RxBool isOnline = true.obs;


  final Map<String, dynamic> newOrder = {
    'earnings': '10.00',
    'isPaid': true,
    'pickupAddress': 'No 2, Balonny Close, Allen Avenue',
    'pickupDistance': '0.5 Km',
    'deliveryAddress': '87, South Lester Street, London Close Belgium',
    'deliveryDistance': '3.5 Km',
    'customerName': 'Vipin Jain',
    'customerPhone': '7878907890',
  };

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
  // final RxList<OrderModel> orders = <OrderModel>[
  //   OrderModel(
  //     id: '1',
  //     customerName: 'Vipin Jain',
  //     customerPhone: '9876543210',
  //     orderNumber: '#1250',
  //     amount: 2300.0,
  //     isPaid: true,
  //     pickupAddressLine1: 'Ananta Stores, 204/C, Apts',
  //     pickupAddressLine2: 'Andheri East 400069',
  //     deliveryAddressLine1: '201/D, Ananta Apts, Near',
  //     deliveryAddressLine2: 'Jal Bhawan, Andheri 400069',
  //     initialStatus: OrderStatus.Pending,
  //   ),
  //   OrderModel(
  //     id: '2',
  //     customerName: 'Akhil Verma',
  //     customerPhone: '9988776655',
  //     orderNumber: '#1251',
  //     amount: 1500.0,
  //     isPaid: false,
  //     pickupAddressLine1: 'Reliance Mart, JVLR',
  //     pickupAddressLine2: 'Powai 400076',
  //     deliveryAddressLine1: 'Hiranandani Gardens',
  //     deliveryAddressLine2: 'Powai 400076',
  //     initialStatus: OrderStatus.Accepted,
  //   ),
  //   OrderModel(
  //     id: '3',
  //     customerName: 'Parikshit Verma',
  //     customerPhone: '9090909090',
  //     orderNumber: '#1252',
  //     amount: 4100.0,
  //     isPaid: true,
  //     pickupAddressLine1: 'DB Mall, Goregaon',
  //     pickupAddressLine2: 'Goregaon West 400104',
  //     deliveryAddressLine1: 'Inorbit Mall, Malad',
  //     deliveryAddressLine2: 'Malad West 400064',
  //     initialStatus: OrderStatus.Accepted,
  //   ),
  //   OrderModel(
  //     id: '4',
  //     customerName: 'Bucky Banaz',
  //     customerPhone: '8899776655',
  //     orderNumber: '#1253',
  //     amount: 750.0,
  //     isPaid: false,
  //     pickupAddressLine1: 'CSMT Station',
  //     pickupAddressLine2: 'Fort 400001',
  //     deliveryAddressLine1: 'Gateway of India',
  //     deliveryAddressLine2: 'Colaba 400005',
  //     initialStatus: OrderStatus.Declined,
  //   ),
  //   OrderModel(
  //     id: '5',
  //     customerName: 'Mansh Kumar',
  //     customerPhone: '9812312312',
  //     orderNumber: '#1254',
  //     amount: 3200.0,
  //     isPaid: true,
  //     pickupAddressLine1: 'Phoenix Marketcity, LBS Road',
  //     pickupAddressLine2: 'Kurla West 400070',
  //     deliveryAddressLine1: 'Seawoods Grand Central',
  //     deliveryAddressLine2: 'Navi Mumbai 400706',
  //     initialStatus: OrderStatus.Pending,
  //   ),
  //   OrderModel(
  //     id: '6',
  //     customerName: 'Aman Sharma',
  //     customerPhone: '9022334455',
  //     orderNumber: '#1255',
  //     amount: 2750.0,
  //     isPaid: true,
  //     pickupAddressLine1: 'Linking Road Market',
  //     pickupAddressLine2: 'Bandra West 400050',
  //     deliveryAddressLine1: 'Infinity Mall',
  //     deliveryAddressLine2: 'Malad West 400064',
  //     initialStatus: OrderStatus.Accepted,
  //   ),
  //   OrderModel(
  //     id: '7',
  //     customerName: 'Rohit Yadav',
  //     customerPhone: '9111122233',
  //     orderNumber: '#1256',
  //     amount: 1200.0,
  //     isPaid: false,
  //     pickupAddressLine1: 'Dadar Flower Market',
  //     pickupAddressLine2: 'Dadar West 400028',
  //     deliveryAddressLine1: 'Matunga Railway Station',
  //     deliveryAddressLine2: 'Matunga 400019',
  //     initialStatus: OrderStatus.Pending,
  //   ),
  //   OrderModel(
  //     id: '8',
  //     customerName: 'Karan Patel',
  //     customerPhone: '9099888777',
  //     orderNumber: '#1257',
  //     amount: 5600.0,
  //     isPaid: true,
  //     pickupAddressLine1: 'Oberoi Mall, Goregaon',
  //     pickupAddressLine2: 'Goregaon East 400063',
  //     deliveryAddressLine1: 'R City Mall',
  //     deliveryAddressLine2: 'Ghatkopar 400077',
  //     initialStatus: OrderStatus.Declined,
  //   ),
  // ].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs; // <-- EMPTY LIST (Yeh sahi hai)

  // Socket listeners ke subscriptions
  late StreamSubscription _newShipmentSub;
  // === CHANGE START: Ise Nullable (?) banao ===
  StreamSubscription? _existingShipmentsListener;
  // === CHANGE END ===
  late StreamSubscription _shipmentStatusSub;

  // Static functions ko real data ke saath update karo
  void acceptDeliveryOrder(String orderId) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status.value = OrderStatus.Accepted;
    socketService.acceptOrder(int.parse(orderId)); // <-- Backend ko batao
  }

  void declineDeliveryOrder(String orderId) {
    final order = orders.firstWhere((o) => o.id == orderId);
    order.status.value = OrderStatus.Declined;
    socketService.rejectOrder(int.parse(orderId)); // <-- Backend ko batao
  }

  @override
  void onInit() {
    super.onInit();

    _loadDriverData();
    _setupSocketListeners(); // <-- Socket listeners ko setup karo

    // === CHANGE START: Naya function call karo ===
    _bindExistingShipments();
    // === CHANGE END ===
  }

  // Tumhara `showNewOrderSheet(OrderModel order)` function sahi hai
  void showNewOrderSheet(OrderModel order) {
    Get.bottomSheet(
      NewOrderSheet(orderData: order), // <-- Map ki jagah OrderModel pass karo
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  Future<void> _loadDriverData() async {
    try {
      isLoading.value = true;

      final driverData = db.driver;
      if (driverData != null) {
        currentDriver.value = driverData;
        print("User:${currentDriver.value?.name}");
      } else {
        print("No driver data found in local DB.");
      }
    } catch (e) {
      print("Failed to load driver data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Yeh function Service ki RxList ko sunega
  void _bindExistingShipments() {
    // 1. Future updates ke liye listen karo
    _existingShipmentsListener =
        socketService.existingShipments.listen((shipmentData) {
          try {
            final newOrders =
            shipmentData.map((json) => OrderModel.fromJson(json)).toList();
            orders.assignAll(newOrders);
            debugPrint(
                "Socket: Updated existing shipments list (${newOrders.length})");
          } catch (e) {
            debugPrint("Error parsing existingShipments: $e");
          }
        });

    // 2. Initial data load karo (agar service me pehle se hai)
    if (socketService.existingShipments.isNotEmpty) {
      try {
        final newOrders = socketService.existingShipments
            .map((json) => OrderModel.fromJson(json))
            .toList();
        orders.assignAll(newOrders);
        debugPrint(
            "Loaded ${newOrders.length} existing shipments from service cache");
      } catch (e) {
        debugPrint("Error parsing cached existingShipments: $e");
      }
    }
  }

  // Naya function socket events sunne ke liye
  void _setupSocketListeners() {
    // 2. Naya order (Yeh sahi hai)
    _newShipmentSub = socketService.newShipmentStream.listen((shipmentJson) {
      try {
        debugPrint("Socket: Received newShipment!");

        // ======================================================
        // 🚀 YEH HAI FIX: Check karo sheet pehle se khuli hai ya nahi
        // ======================================================
        if (Get.isBottomSheetOpen == true) {
          debugPrint(
              "Socket: Ignoring newShipment, a bottom sheet is already open.");
          return; // Sheet pehle se khuli hai, function yahin rok do
        }
        // ======================================================

        final newOrder = OrderModel.fromJson(shipmentJson);

        // List mein add karo (agar pehle se nahi hai)
        if (!orders.any((o) => o.id == newOrder.id)) {
          orders.insert(0, newOrder); // Sabse upar dikhao
        }

        // Popup sheet dikhao
        showNewOrderSheet(newOrder);
      } catch (e) {
        debugPrint("Error parsing newShipment: $e");
      }
    });

    // 3. Status update (Yeh sahi hai)
    _shipmentStatusSub = socketService.shipmentStatusStream.listen((statusData) {
      try {
        final String shipmentId = statusData['shipmentId'].toString();
        final String status = statusData['status'];

        final index = orders.indexWhere((o) => o.id == shipmentId);
        if (index != -1) {
          if (status == 'in_transit' ||
              status == 'rejected' ||
              status == 'cancelled') {
            // Agar kisi aur ne accept/reject kar diya, toh list se hata do
            orders.removeAt(index);
            debugPrint("Socket: Removed order $shipmentId (status: $status)");
          }
        }
      } catch (e) {
        debugPrint("Error handling shipment_status: $e");
      }
    });
  }

  // Tumhare rejectOrder aur acceptOrder functions sahi hain
  void rejectOrder(OrderModel order) {
    Get.back(); // Bottom sheet band karo
    declineDeliveryOrder(order.id); // Main function call karo
  }

  void acceptOrder(OrderModel order) {
    Get.back(); // Bottom sheet band karo
    acceptDeliveryOrder(order.id); // Main function call karo
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
    // Listeners ko cancel karo
    _newShipmentSub.cancel();
    _existingShipmentsListener?.cancel();
    _shipmentStatusSub.cancel();
    super.onClose();
  }
}