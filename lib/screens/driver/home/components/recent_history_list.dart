import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../../../../models/driver_order_model.dart';
import '../../../../modules/controllers/home/driver_home_controller.dart';
import '../../driver_rides_screens.dart';

class RecentHistoryList extends StatelessWidget {
  final DriverHomeController controller;
  const RecentHistoryList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recentHistory'.tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const DriverRideScreen()),
                child: Text(
                  'viewAll'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.recentOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconlyLight.document,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'noRecentOrders'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchRecentHistory,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: controller.recentOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.recentOrders[index];
                    return _OrderHistoryCard(
                      order: order,
                      controller: controller,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1, color: Colors.black12);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final DriverHomeController controller;

  const _OrderHistoryCard({required this.order, required this.controller});

  String _getInitial() {
    try {
      final name = (order.dropoff?.name?.isNotEmpty == true)
          ? order.dropoff!.name!
          : (order.dropoffAddressLine1?.isNotEmpty == true
                ? order.dropoffAddressLine1!
                : '');
      if (name.isNotEmpty) {
        return name[0].toUpperCase();
      }
    } catch (e) {
      debugPrint('Error in _getInitial: $e');
    }
    return '#';
  }

  String _getDisplayName() {
    try {
      if (order.dropoff?.name?.isNotEmpty == true) {
        return order.dropoff!.name!;
      }
      // Use first part of address as name
      final address = order.dropoffAddressLine1 ?? '';
      if (address.length > 20) {
        return '${address.substring(0, 20)}...';
      }
      return address.isNotEmpty ? address : 'Order #${order.id ?? 'N/A'}';
    } catch (e) {
      debugPrint('Error in _getDisplayName: $e');
      return 'Order #${order.id ?? 'N/A'}';
    }
  }

  Color _getStatusColor() {
    switch (order.status.value) {
      case OrderStatus.Delivered:
        return Colors.green;
      case OrderStatus.InTransit:
      case OrderStatus.PickedUp:
      case OrderStatus.Accepted:
      case OrderStatus.Assigned:
        return Colors.orange;
      case OrderStatus.Cancelled:
      case OrderStatus.Declined:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = controller.formatOrderTime(order.createdAt);
    final amount = (order.estimatedCost ?? 0.0).toStringAsFixed(0);
    final statusStr = order.status.value.toString().split('.').last;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        radius: 20.sp,
        backgroundColor: AppColors.driverCard,
        child: Text(
          _getInitial(),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _getDisplayName(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusStr,
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            const Icon(IconlyLight.calendar, size: 14, color: Colors.black54),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                timeLabel,
                style: TextStyle(color: Colors.black54, fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
      trailing: Text(
        '₹$amount',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 15.sp,
        ),
      ),
    );
  }
}
