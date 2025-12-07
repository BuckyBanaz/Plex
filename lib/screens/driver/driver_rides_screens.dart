// file: screens/orders/orders_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/domain/repository/repository_imports.dart'; // adjust to your repo locator
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';

import '../../models/driver_order_model.dart';

/// Controller: fetches shipments, groups them and provides navigation + driver location
class MyOrdersController extends GetxController {
  final ShipmentRepository _shipmentRepository = Get.find<ShipmentRepository>();

  // grouped map: {'Today': [OrderModel,...], 'Yesterday': [...], '03 Dec, 2025': [...]}
  final grouped = <String, List<OrderModel>>{}.obs;

  final selectedOrder = Rx<OrderModel?>(null);
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  // driver location for details
  final isLoadingDriverLocation = false.obs;
  final driverLocation = Rx<LatLng?>(null);

  // optional filter like tabs (All, InTransit, Delivered, Cancelled)
  final activeTab = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAndGroupShipments();
  }

  Future<void> fetchAndGroupShipments() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final res = await _shipmentRepository.getShipments(parseToModels: true);

      if (res is Map && res.containsKey('error')) {
        errorMessage.value = res['error'].toString();
        grouped.value = {};
        return;
      }

      if (res is Map && res['success'] != true) {
        errorMessage.value = res['message']?.toString() ?? 'Failed to fetch shipments';
        grouped.value = {};
        return;
      }

      List<OrderModel> orders;
      if (res is Map && res['shipments'] is List<OrderModel>) {
        orders = List<OrderModel>.from(res['shipments'] as List<OrderModel>);
      } else if (res is List<OrderModel>) {
        orders = List<OrderModel>.from(res as List<OrderModel>);
      } else {
        // Fallback attempt to parse via OrderModel.listFromApi if repository returned raw JSON
        try {
          final raw = res;
          orders = OrderModel.listFromApi(raw);
        } catch (_) {
          orders = [];
        }
      }

      // Optional: filter per activeTab
      List<OrderModel> filteredList = orders;
      if (activeTab.value != 'All') {
        final a = activeTab.value.toLowerCase();
        filteredList = orders.where((o) {
          final s = o.status.value.toString().toLowerCase();
          return s.contains(a);
        }).toList();
      }

      // Sort by createdAt desc (most recent first)
      filteredList.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      // Group them by day label
      final Map<String, List<OrderModel>> groups = {};
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      for (var o in filteredList) {
        final created = o.createdAt;
        String label;
        if (created == null) {
          label = DateFormat('dd MMM, yyyy').format(now); // fallback to today
        } else {
          final createdDate = DateTime(created.year, created.month, created.day);
          if (createdDate == today) {
            label = 'Today';
          } else if (createdDate == yesterday) {
            label = 'Yesterday';
          } else {
            label = DateFormat('dd MMM, yyyy').format(createdDate);
          }
        }
        groups.putIfAbsent(label, () => []).add(o);
      }

      // Sort keys descending: Today -> Yesterday -> newest date -> oldest
      final sortedKeys = groups.keys.toList()
        ..sort((a, b) {
          final aDate = _parseGroupKeyToDate(a);
          final bDate = _parseGroupKeyToDate(b);
          return bDate.compareTo(aDate);
        });

      final Map<String, List<OrderModel>> sortedMap = {};
      for (var k in sortedKeys) {
        final list = groups[k]!;
        // sort rides within group by createdAt desc
        list.sort((x, y) {
          final xd = x.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final yd = y.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return yd.compareTo(xd);
        });
        sortedMap[k] = list;
      }

      grouped.value = sortedMap;
    } catch (e, st) {
      errorMessage.value = e.toString();
      debugPrint('fetchAndGroupShipments error: $e\n$st');
      grouped.value = {};
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    activeTab.value = tab;
    fetchAndGroupShipments();
  }

// controller
  Future<void> refresh() async => await fetchAndGroupShipments();


  void goToOrderDetails(OrderModel order) {
    selectedOrder.value = order;
    // optionally fetch driver location for in-transit orders
    final status = order.status.value;
    if (status == OrderStatus.InTransit ||
        status == OrderStatus.Accepted ||
        status == OrderStatus.Assigned) {
      // fetchDriverLocation(order.id);
    }
    // Get.to(() => const UserOrderDetailsScreen());
  }

  // Future<void> fetchDriverLocation(String shipmentId) async {
  //   try {
  //     isLoadingDriverLocation.value = true;
  //     final result = await _shipmentRepository.getDriverLocation(shipmentId: shipmentId);
  //
  //     if (result is Map && result.containsKey('error')) {
  //       debugPrint('Error fetching driver location: ${result['error']}');
  //       driverLocation.value = null;
  //       return;
  //     }
  //
  //     if (result is Map && result['success'] == true && result['lat'] != null && result['lng'] != null) {
  //       driverLocation.value = LatLng(result['lat'] as double, result['lng'] as double);
  //     } else {
  //       driverLocation.value = null;
  //       debugPrint('Driver location not available: ${result['message'] ?? result}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetchDriverLocation: $e');
  //     driverLocation.value = null;
  //   } finally {
  //     isLoadingDriverLocation.value = false;
  //   }
  // }

  DateTime _parseGroupKeyToDate(String key) {
    if (key == 'Today') return DateTime.now();
    if (key == 'Yesterday') return DateTime.now().subtract(const Duration(days: 1));
    try {
      return DateFormat('dd MMM, yyyy').parse(key);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}

/// Screen: displays grouped orders using OrderModel
class DriverRideScreen extends StatelessWidget {
  const DriverRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyOrdersController());
    final arg = Get.arguments;
    final bool showTitle = arg != null && arg.toString() == 'navigation';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _OrdersTopBar(showTitle: showTitle),
            const SizedBox(height: 8),
            _OrdersTabBar(controller: controller),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value != null) {
                  return Center(child: Text(controller.errorMessage.value!));
                }

                final entries = controller.grouped.entries.toList();
                if (entries.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final key = entry.key;
                      final list = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              key,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          ...list.map((o) => _OrderCard(order: o, onTap: () => controller.goToOrderDetails(o))).toList(),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar (search/filter + title)
class _OrdersTopBar extends StatelessWidget {
  final bool showTitle;
  const _OrdersTopBar({this.showTitle = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (showTitle) ...[
            IconButton(icon: const Icon(CupertinoIcons.back), onPressed: () => Get.back()),
            const SizedBox(width: 6),
          ],
          const Expanded(
            child: Text(
              'My Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundIconButton(icon: CupertinoIcons.search, onTap: () {}),
              const SizedBox(width: 10),
              RoundIconButton(icon: IconlyLight.filter, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoundIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6ECF5), width: 2),
        ),
        child: Center(child: Icon(icon, size: 22, color: AppColors.secondary)),
      ),
    );
  }
}

/// Tab bar for filtering by status (All, InTransit, Delivered, Cancelled)
class _OrdersTabBar extends StatelessWidget {
  final MyOrdersController controller;
  const _OrdersTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeTab.value;
      return Row(
        children: [
          Expanded(child: _TabButton(label: 'All', selected: active == 'All', onTap: () => controller.setTab('All'))),
          Expanded(child: _TabButton(label: 'InTransit', selected: active == 'InTransit', onTap: () => controller.setTab('InTransit'))),
          Expanded(child: _TabButton(label: 'Delivered', selected: active == 'Delivered', onTap: () => controller.setTab('Delivered'))),
          Expanded(child: _TabButton(label: 'Cancelled', selected: active == 'Cancelled', onTap: () => controller.setTab('Cancelled'))),
        ],
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: selected ? Colors.black : Colors.grey.shade700)),
            ),
            Container(
              // decoration: const Duration(milliseconds: 200),
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.grey.shade200),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget to display order summary
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const _OrderCard({required this.order, this.onTap});

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _timeLabel(order.createdAt);
    final price = order.estimatedCost.toStringAsFixed(0);
    final statusStr = order.status.value.toString().split('.').last;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // left icons
                  Column(
                    children: [
                      Icon(Icons.my_location, color: AppColors.primary, size: 24),
                      Expanded(child: Container(width: 2, color: AppColors.primary.withOpacity(0.4))),
                      Icon(IconlyLight.location, color: AppColors.primary, size: 26),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // addresses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.pickupAddressLine1 + (order.pickupAddressLine2.isNotEmpty ? ', ${order.pickupAddressLine2}' : ''),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          order.dropoffAddressLine1 + (order.dropoffAddressLine2.isNotEmpty ? ', ${order.dropoffAddressLine2}' : ''),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  // time & status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timeLabel, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status.value).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusStr,
                          style: TextStyle(color: _statusColor(order.status.value), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.money, size: 20),
                    const SizedBox(width: 6),
                    Text('₹$price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(width: 14),
                if (order.paymentMethod.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.payment, size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.InTransit:
      case OrderStatus.Assigned:
      case OrderStatus.Accepted:
        return Colors.orange;
      case OrderStatus.Delivered:
        return Colors.green;
      case OrderStatus.Cancelled:
      case OrderStatus.Declined:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
