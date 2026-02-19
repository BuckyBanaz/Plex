// controllers/home/driver_home_controller.dart
import 'dart:async';
import 'package:flutter/material.dart' show Center, CircularProgressIndicator, Colors, debugPrint;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plex_user/services/domain/service/socket/socket_service.dart';
import 'package:plex_user/services/domain/service/socket/driver_order_socket.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
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

  // Recent completed orders (max 5)
  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDriverData();
    
    // Check for active orders when driver opens app
    _restoreActiveOrder();
    
    // Load recent history
    fetchRecentHistory();

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
      try {
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

          try {
            // Connect low-level socket
            socketService.connect(token, driver.id);

            // Start driver-specific listeners (parsing & populating orders)
            driverOrderSocket.start();

            // Also attach controller-level socket listeners (for showing bottom sheet)
            if (_onNewShipmentHandler != null) {
              socketService.on('newShipment', _onNewShipmentHandler!);
            }
            if (_onSocketErrorHandler != null) {
              socketService.on('error', _onSocketErrorHandler!);
            }
          } catch (e) {
            debugPrint('DriverHomeController: error connecting socket: $e');
            isOnline.value = false; // revert on error
          }
        } else {
          // stop listening and disconnect
          try {
            if (_onNewShipmentHandler != null) {
              socketService.off('newShipment', _onNewShipmentHandler);
            }
            if (_onSocketErrorHandler != null) {
              socketService.off('error', _onSocketErrorHandler);
            }
          } catch (e) {
            debugPrint('DriverHomeController: error detaching socket listeners: $e');
          }

          try {
            // Stop high-level socket handlers and clear local orders
            driverOrderSocket.stop();
          } catch (e) {
            debugPrint('DriverHomeController: error stopping driverOrderSocket: $e');
          }

          try {
            // Disconnect low-level socket
            socketService.disconnect();
          } catch (e) {
            debugPrint('DriverHomeController: error disconnecting socket: $e');
          }
        }
      } catch (e) {
        debugPrint('DriverHomeController: error in isOnline handler: $e');
        // Don't crash, just log
      }
    });


  }

  Future<void> _loadDriverData() async {
    try {
      isLoading.value = true;
      
      // First load from local storage for instant display
      final cachedDriver = db.driver;
      if (cachedDriver != null) {
        currentDriver.value = cachedDriver;
      }
      
      // Then fetch fresh profile from API to get latest data (including vehicles)
      try {
        final profileData = await userRepo.getProfile();
        if (profileData != null) {
          debugPrint('📱 Fresh profile data from API: $profileData');
          
          // Parse vehicles from API response with error handling
          List<VehicleModel> vehicles = [];
          try {
            if (profileData['vehicles'] != null && profileData['vehicles'] is List) {
              final vehiclesList = profileData['vehicles'] as List;
              vehicles = vehiclesList
                  .where((v) => v != null)
                  .map((v) {
                    try {
                      return VehicleModel.fromJson(Map<String, dynamic>.from(v));
                    } catch (e) {
                      debugPrint('Error parsing vehicle: $e');
                      return null;
                    }
                  })
                  .whereType<VehicleModel>()
                  .toList();
              debugPrint('🚗 Vehicles from API: ${vehicles.length}');
            }
          } catch (e) {
            debugPrint('Error parsing vehicles: $e');
            vehicles = cachedDriver?.vehicles ?? [];
          }
          
          // Update driver model with fresh data
          final defaultLocation = LocationModel(
            latitude: 0.0,
            longitude: 0.0,
            accuracy: 0.0,
            heading: 0.0,
            speed: 0.0,
            recordedAt: DateTime.now(),
          );
          
          final updatedDriver = DriverUserModel(
            id: profileData['id'] ?? cachedDriver?.id ?? 0,
            name: (profileData['name'] ?? cachedDriver?.name ?? '').toString(),
            email: (profileData['email'] ?? cachedDriver?.email ?? '').toString(),
            mobile: (profileData['mobile'] ?? cachedDriver?.mobile ?? '').toString(),
            userType: (profileData['userType'] ?? cachedDriver?.userType ?? 'driver').toString(),
            kycStatus: (profileData['kycStatus'] ?? cachedDriver?.kycStatus ?? '').toString(),
            mobileVerified: profileData['mobileVerified'] ?? cachedDriver?.mobileVerified ?? false,
            emailVerified: profileData['emailVerified'] ?? cachedDriver?.emailVerified ?? false,
            createdAt: cachedDriver?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
            location: cachedDriver?.location ?? defaultLocation,
            vehicles: vehicles,
            currentBalance: cachedDriver?.currentBalance,
          );
          
          // Update local storage with fresh data
          try {
            await db.putDriver(updatedDriver);
            currentDriver.value = updatedDriver;
            debugPrint('✅ Driver data refreshed with ${vehicles.length} vehicles');
          } catch (e) {
            debugPrint('Error saving driver to local storage: $e');
            // Still update the value even if save fails
            currentDriver.value = updatedDriver;
          }
        }
      } catch (e) {
        debugPrint("Error fetching profile from API: $e");
        // Keep cached driver if API fails
        if (currentDriver.value == null && cachedDriver != null) {
          currentDriver.value = cachedDriver;
        }
      }
    } catch (e) {
      debugPrint("Failed to load driver data: $e");
      // Ensure we have at least cached driver
      if (currentDriver.value == null) {
        final cachedDriver = db.driver;
        if (cachedDriver != null) {
          currentDriver.value = cachedDriver;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch recent 5 completed orders for history section
  Future<void> fetchRecentHistory() async {
    try {
      isLoadingHistory.value = true;
      
      try {
        final ShipmentRepository repo = Get.find<ShipmentRepository>();
        final dynamic res = await repo.getShipments(parseToModels: true);
        
        List<OrderModel> allOrders = [];
        
        if (res is Map<String, dynamic>) {
          if (res.containsKey('error') || res['success'] != true) {
            debugPrint('fetchRecentHistory error: ${res['error'] ?? res['message']}');
            return;
          }
          
          final dynamic shipments = res['shipments'];
          if (shipments is List<OrderModel>) {
            allOrders = List<OrderModel>.from(shipments);
          } else if (shipments is List) {
            for (final item in shipments) {
              try {
                if (item is OrderModel) {
                  allOrders.add(item);
                } else if (item is Map) {
                  allOrders.add(OrderModel.fromJson(Map<String, dynamic>.from(item)));
                }
              } catch (e) {
                debugPrint('Error parsing order item in fetchRecentHistory: $e');
                // Skip invalid items
              }
            }
          }
        } else if (res is List) {
          for (final item in res) {
            try {
              if (item is OrderModel) {
                allOrders.add(item);
              } else if (item is Map) {
                allOrders.add(OrderModel.fromJson(Map<String, dynamic>.from(item)));
              }
            } catch (e) {
              debugPrint('Error parsing order item in fetchRecentHistory: $e');
              // Skip invalid items
            }
          }
        }
        
        // Sort by createdAt descending (most recent first)
        try {
          allOrders.sort((a, b) {
            try {
              final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bDate.compareTo(aDate);
            } catch (e) {
              debugPrint('Error sorting orders: $e');
              return 0;
            }
          });
        } catch (e) {
          debugPrint('Error in sort: $e');
        }
        
        // Take only first 5
        recentOrders.value = allOrders.take(5).toList();
        
        debugPrint('fetchRecentHistory: loaded ${recentOrders.length} recent orders');
      } catch (e) {
        debugPrint('fetchRecentHistory API error: $e');
        // Keep existing orders if API fails
      }
    } catch (e) {
      debugPrint('fetchRecentHistory error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }
  
  /// Format date for display
  String formatOrderTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(dt.year, dt.month, dt.day);
    
    if (orderDate == today) {
      return 'Today at ${DateFormat('h:mm a').format(dt)}';
    } else if (orderDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dt)}';
    } else {
      return DateFormat('dd MMM, h:mm a').format(dt);
    }
  }

  /// Restore active order when driver reopens app
  /// Fetches active orders from backend and navigates to tracking if found
  Future<void> _restoreActiveOrder() async {
    try {
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 🔄 CHECKING FOR ACTIVE ORDERS...');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      
      // First check local storage for saved order
      try {
        final savedOrder = db.driverCurrentOrder;
        if (savedOrder != null) {
          debugPrint('║ Found saved order in local storage: ${savedOrder.id}');
        }
      } catch (e) {
        debugPrint('Error reading saved order from local storage: $e');
      }
      
      // Fetch active orders from backend
      try {
        final ShipmentRepository repo = Get.find<ShipmentRepository>();
        final result = await repo.getDriverActiveOrders();
        
        if (result['success'] != true) {
          debugPrint('║ No active orders found or error: ${result['message'] ?? result['error']}');
          return;
        }
        
        final List<OrderModel> activeOrders = result['orders'] ?? [];
        
        if (activeOrders.isEmpty) {
          debugPrint('║ No active orders to restore');
          // Clear saved order if backend says no active orders
          try {
            db.deleteDriverCurrentOrder();
          } catch (e) {
            debugPrint('Error deleting driver current order: $e');
          }
          return;
        }
        
        // Get the most recent active order (first one - backend returns ordered by updatedAt DESC)
        final OrderModel activeOrder = activeOrders.first;
        
        // Validate order has required fields
        if (activeOrder.id == null || activeOrder.pickup == null || activeOrder.dropoff == null) {
          debugPrint('║ Invalid active order data, skipping restore');
          return;
        }
        
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ ✅ ACTIVE ORDER FOUND!');
        debugPrint('║ Order ID: ${activeOrder.id}');
        debugPrint('║ Status: ${activeOrder.status.value}');
        debugPrint('║ Pickup: ${activeOrder.pickup.address}');
        debugPrint('║ Dropoff: ${activeOrder.dropoff.address}');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        
        // Save to local storage
        try {
          await db.putDriverCurrentOrder(activeOrder);
        } catch (e) {
          debugPrint('Error saving active order to local storage: $e');
        }
        
        // Navigate to tracking screen with small delay for UI to settle
        await Future.delayed(const Duration(milliseconds: 500));
        
        try {
          final Map<String, dynamic> args = {
            'shipment': {
              'id': activeOrder.id,
              'orderId': activeOrder.orderId ?? '',
              'pickup': {
                'name': activeOrder.pickup.name ?? '',
                'phone': activeOrder.pickup.phone ?? '',
                'address': activeOrder.pickup.address ?? '',
                'latitude': activeOrder.pickup.latitude ?? 0.0,
                'longitude': activeOrder.pickup.longitude ?? 0.0,
              },
              'dropoff': {
                'name': activeOrder.dropoff.name ?? '',
                'phone': activeOrder.dropoff.phone ?? '',
                'address': activeOrder.dropoff.address ?? '',
                'latitude': activeOrder.dropoff.latitude ?? 0.0,
                'longitude': activeOrder.dropoff.longitude ?? 0.0,
              },
              'invoiceNumber': activeOrder.invoiceNumber ?? '',
              'estimatedCost': activeOrder.estimatedCost ?? 0.0,
              'driverId': activeOrder.driverId ?? 0,
              'status': activeOrder.status.value.toString(),
            },
            'restored': true, // Flag to indicate this is a restored order
          };
          
          showToast(message: 'Resuming your active delivery');
          Get.toNamed(AppRoutes.driverOrderTracking, arguments: args);
        } catch (e) {
          debugPrint('Error navigating to tracking screen: $e');
        }
      } catch (e) {
        debugPrint('Error fetching active orders: $e');
      }
      
    } catch (e) {
      debugPrint('Error restoring active order: $e');
      // Don't crash, just log
    }
  }

  void showNewOrderSheet(OrderModel order) {
    try {
      // Validate order before showing sheet
      if (order.id == null || order.pickup == null || order.dropoff == null) {
        debugPrint('Invalid order data, cannot show sheet');
        return;
      }
      
      Get.bottomSheet(
        NewOrderSheet(orderData: order),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
      );
    } catch (e) {
      debugPrint('Error showing new order sheet: $e');
      // Don't crash, just log
    }
  }

  /// Accept order flow (uses repository; optimistic UI update + rollback on failure).
  void acceptOrder(OrderModel order) async {
    bool loaderShown = false;

    try {
      // Validate order before accepting
      if (order.id == null || order.pickup == null || order.dropoff == null) {
        showToast(message: 'Invalid order data');
        return;
      }

      // show loader
      if (Get.isDialogOpen == false) {
        try {
          Get.dialog(
            Center(child: CircularProgressIndicator(color: Colors.orange)),
            barrierDismissible: false,
          );
          loaderShown = true;
        } catch (e) {
          debugPrint('Error showing loader: $e');
        }
      }

      // close bottom sheet if any
      try {
        if (Get.isBottomSheetOpen == true) Get.back();
      } catch (e) {
        debugPrint('Error closing bottom sheet: $e');
      }

      // optimistic in-memory update
      try {
        order.status.value = OrderStatus.Assigned;
      } catch (_) {}

      final ShipmentRepository repo = Get.find<ShipmentRepository>();
      final shipmentId = int.tryParse(order.id.toString()) ?? 0;
      if (shipmentId == 0) {
        showToast(message: 'Invalid order ID');
        if (loaderShown && Get.isDialogOpen == true) {
          Get.back();
        }
        return;
      }

      final result = await repo.acceptShipment(
        shipmentId: shipmentId,
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
      try {
        final Map<String, dynamic> args = {
          'shipment': {
            'id': finalOrder.id ?? '',
            'orderId': finalOrder.orderId ?? '',
            'pickup': {
              'name': finalOrder.pickup?.name ?? '',
              'phone': finalOrder.pickup?.phone ?? '',
              'address': finalOrder.pickup?.address ?? '',
              'latitude': finalOrder.pickup?.latitude ?? 0.0,
              'longitude': finalOrder.pickup?.longitude ?? 0.0,
            },
            'dropoff': {
              'name': finalOrder.dropoff?.name ?? '',
              'phone': finalOrder.dropoff?.phone ?? '',
              'address': finalOrder.dropoff?.address ?? '',
              'latitude': finalOrder.dropoff?.latitude ?? 0.0,
              'longitude': finalOrder.dropoff?.longitude ?? 0.0,
            },
            'invoiceNumber': finalOrder.invoiceNumber ?? '',
            'estimatedCost': finalOrder.estimatedCost ?? 0.0,
            'driverId': finalOrder.driverId ?? 0,
            'paymentMethod': finalOrder.paymentMethod ?? '',
            'paymentStatus': finalOrder.paymentStatus ?? '',
            'status': finalOrder.status.value.toString(),
          }
        };
        Get.toNamed(AppRoutes.driverOrderTracking, arguments: args);
      } catch (e) {
        debugPrint('Error navigating to tracking: $e');
        showToast(message: 'Error navigating to tracking screen');
      }
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

  /// Pull-to-refresh handler for driver jobs list.
  Future<void> refreshOrders() async {
    try {
      final driver = currentDriver.value;
      if (driver == null) return;

      if (!socketService.isConnected) {
        final token = db.accessToken ?? '';
        if (token.isEmpty) return;
        socketService.connect(token, driver.id);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        driverOrderSocket.start();
      }

      // Ask server to resend current shipments
      socketService.emit('driver_ready', {'driverId': driver.id});
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('DriverHomeController.refreshOrders error: $e');
    }
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
