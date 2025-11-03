// /screens/order_card_widget.dart

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/constant/app_colors.dart';

import '../../../../constant/app_assets.dart';
import '../../../../modules/controllers/orders/order_controller.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  const OrderCard({super.key, required this.order});

  Widget _buildStatusChip(OrderStatus status) {

    String text;

    switch (status) {
      case OrderStatus.Complete:

        text = "Complete";
        break;
      case OrderStatus.Pending:
        text = "Pending";
        break;
      case OrderStatus.Cancelled:
        text = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAddressSection(
      {required String title,
        required String name,
        required String phone,
        required String address,
        required Color iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4.0),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: "$name ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: phone,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          address,
          style: const TextStyle(
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String vehicleIconAsset = AppAssets.bike;
    if (order.vehicleType == "Car") {
      vehicleIconAsset = AppAssets.car;
    } else if (order.vehicleType == "Van") {
      vehicleIconAsset = AppAssets.van;
    }

    return GestureDetector(
      onTap: () {
        // Controller ke through details screen par navigate karein
        Get.find<UserOrderController>().goToOrderDetails(order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.primarySwatch.shade50,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppColors.primary,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(
                            text: "Order id - ",
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: order.orderId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "${order.date}, ${order.time}",
                      style:
                      const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
                // Status Chip
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      vehicleIconAsset,
                      matchTextDirection: true,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Icon(Icons.circle, color: AppColors.primary, size: 12.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: DottedLine(
                          direction: Axis.vertical,
                          lineLength: 50,
                          dashColor: AppColors.secondary,
                          dashGapLength: 3.0,
                          dashRadius: 2.0,
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 16.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressSection(
                        title: "Pickup",
                        name: order.pickupName,
                        phone: order.pickupPhone,
                        address: order.pickupAddress,
                        iconColor: AppColors.primary,
                      ),
                      const SizedBox(height: 6.0),
                      _buildAddressSection(
                        title: "Drop off",
                        name: order.dropoffName,
                        phone: order.dropoffPhone,
                        address: order.dropoffAddress,
                        iconColor: AppColors.secondary,
                      ),
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
}