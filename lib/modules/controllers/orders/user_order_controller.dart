import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/driver_order_model.dart';
import '../../../services/domain/repository/repository_imports.dart';
// path adjust as needed
import '../../../screens/individual/order/user_order_details_screen.dart';
import '../../../services/domain/service/socket/user_order_socket.dart';

class UserOrderController extends GetxController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();

  var groupedOrders = <String, List<OrderModel>>{}.obs;
  var selectedOrder = Rx<OrderModel?>(null);

  var isLoading = false.obs;
  var errorMessage = Rx<String?>(null);
  var isLoadingDriverLocation = false.obs;

  var driverLocation = Rx<LatLng?>(null);

  @override
  void onInit() {
    super.onInit();
    Get.put<UserOrderSocket>(UserOrderSocket());

    fetchAndGroupShipments();
  }

  var selectedVehicleIndex = "Bike".obs;

  Future<void> fetchAndGroupShipments() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final res = await _shipmentRepository.getShipments(parseToModels: true);

      if (res.containsKey('error')) {
        errorMessage.value = res['error'].toString();
        groupedOrders.value = {};
        return;
      }

      if (res['success'] != true) {
        // if API returned success:false, show message
        errorMessage.value =
            res['message']?.toString() ?? 'Failed to fetch shipments';
        groupedOrders.value = {};
        return;
      }

      final List<OrderModel> orders =
          (res['shipments'] as List<OrderModel>?) ?? [];

      // Sort orders by createdAt descending (most recent first)
      orders.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      // Group into Today / Yesterday / Earlier
      final Map<String, List<OrderModel>> grouped = {
        'Today': [],
        'Yesterday': [],
        'Earlier': [],
      };

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      for (final order in orders) {
        final created = order.createdAt;
        if (created == null) {
          grouped['Earlier']!.add(order);
          continue;
        }
        final createdDate = DateTime(created.year, created.month, created.day);
        if (createdDate == today) {
          grouped['Today']!.add(order);
        } else if (createdDate == yesterday) {
          grouped['Yesterday']!.add(order);
        } else {
          grouped['Earlier']!.add(order);
        }
      }

      // Remove empty groups for cleaner UI if desired:
      final Map<String, List<OrderModel>> finalMap = {};
      grouped.forEach((k, v) {
        if (v.isNotEmpty) finalMap[k] = v;
      });

      // If all groups empty but orders exist (edge case), put into Earlier
      if (finalMap.isEmpty && orders.isNotEmpty) {
        finalMap['Orders'] = orders;
      }

      groupedOrders.value = finalMap;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('fetchAndGroupShipments error: $e');
      groupedOrders.value = {};
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() => fetchAndGroupShipments();

  void goToOrderDetails(OrderModel order) {
    selectedOrder.value = order;
    // Fetch driver location when viewing order details
    if (order.status.value == OrderStatus.InTransit ||
        order.status.value == OrderStatus.Accepted ||
        order.status.value == OrderStatus.Assigned) {
      fetchDriverLocation(order.id);
    }
    // navigate to details screen
    Get.to(() => const UserOrderDetailsScreen());
  }

  Future<void> fetchDriverLocation(String shipmentId) async {
    try {
      isLoadingDriverLocation.value = true;
      final result = await _shipmentRepository.getDriverLocation(
        shipmentId: shipmentId,
      );

      if (result.containsKey('error')) {
        debugPrint('Error fetching driver location: ${result['error']}');
        driverLocation.value = null;
        return;
      }

      if (result['success'] == true &&
          result['lat'] != null &&
          result['lng'] != null) {
        driverLocation.value = LatLng(
          result['lat'] as double,
          result['lng'] as double,
        );
        debugPrint(
          'Driver location fetched: ${driverLocation.value?.latitude}, ${driverLocation.value?.longitude}',
        );
      } else {
        driverLocation.value = null;
        debugPrint('Driver location not available: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Error in controller while fetching driver location: $e');
      driverLocation.value = null;
    } finally {
      isLoadingDriverLocation.value = false;
    }
  }
}
