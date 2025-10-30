import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconly/iconly.dart';

import '../../../constant/app_colors.dart';
import '../../../models/driver_order_model.dart';
import '../../../modules/controllers/home/driver_home_controller.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final DriverHomeController controller = Get.find<DriverHomeController>();

  OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.driverCardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 24, thickness: 1),

            _buildAddressRow(
              icon: Icons.my_location,
              title: 'pickup'.tr,
              line1: order.pickupAddressLine1,
              line2: order.pickupAddressLine2,
            ),
            const SizedBox(height: 16),

            _buildAddressRow(
              icon: IconlyLight.location,
              title: 'delivery'.tr,
              line1: order.deliveryAddressLine1,
              line2: order.deliveryAddressLine2,
            ),
            const SizedBox(height: 16),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.driverCard,
          child: Icon(Icons.person_outline, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${'orderNo'.tr} ${order.orderNumber}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${order.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Icon(
                  order.isPaid ? Icons.check_circle : Icons.cancel,
                  color: order.isPaid
                      ? AppColors.greenPaid
                      : AppColors.redUnpaid,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  order.isPaid ? 'paid'.tr : 'unpaid'.tr,
                  style: TextStyle(
                    color: order.isPaid
                        ? AppColors.greenPaid
                        : AppColors.redUnpaid,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String title,
    required String line1,
    required String line2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.darkOrangeIcon, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(line1, style: const TextStyle(color: Colors.black54)),
              Text(line2, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        _buildCircleButton(IconlyLight.call),
        const SizedBox(width: 8),
        _buildCircleButton(CupertinoIcons.location),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: AppColors.primarySwatch.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.darkOrangeIcon, size: 18),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.declineDeliveryOOrder(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreyButton,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('rejectOrder'.tr),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.acceptDeliveryOrder(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('acceptOrder'.tr),
          ),
        ),
      ],
    );
  }
}
