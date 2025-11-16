import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconly/iconly.dart';

import '../../../constant/app_colors.dart';
import '../../../models/driver_order_model.dart';
import '../../../modules/controllers/home/driver_home_controller.dart';

class DriverJobsCard extends StatelessWidget {
  final OrderModel order;
  final DriverHomeController controller = Get.find<DriverHomeController>();

  DriverJobsCard({super.key, required this.order});

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

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    children: [
                      Icon(Icons.my_location,
                          color: AppColors.darkOrangeIcon, size: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: DottedLine(
                          direction: Axis.vertical,
                          lineLength: 45,
                          dashColor: AppColors.darkOrangeIcon.withOpacity(0.5),
                          // dashGapLength: 2.0,
                          lineThickness: 2,
                          dashRadius: 6.0,
                        ),
                      ),
                      Icon(IconlyLight.location,
                          color: AppColors.darkOrangeIcon, size: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 12), // Spacer

                // Address info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressInfo(
                        title: 'pickup'.tr,
                        line1: order.pickup.address,
                        // line2: order.pickupAddressLine2,
                      ),
                      const SizedBox(height: 16), // Spacer between addresses
                      _buildAddressInfo(
                        title: 'delivery'.tr,
                        line1: order.dropoff.address,
                        // line2: order.deliveryAddressLine2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 2. END REPLACEMENT

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
              order.pickup.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${'orderNo'.tr} ${order.id}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${order.estimatedCost.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Icon(
                 order.paymentStatus != "pending" ? Icons.check_circle : Icons.cancel,
                  color: order.paymentStatus != "pending"
                      ? AppColors.greenPaid
                      : AppColors.redUnpaid,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  order.paymentStatus != "pending" ? 'paid'.tr : 'unpaid'.tr,
                  style: TextStyle(
                    color: order.paymentStatus != "pending"
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

  // <-- 3. WIDGET KO RENAME KIYA (buildAddressRow -> buildAddressInfo)

  Widget _buildAddressInfo({
    required String title,
    required String line1,
    // required String line2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              // Text(line2, style: const TextStyle(color: Colors.black54)),
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
            onPressed: () {
              controller.rejectOrder(order);
            },
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
            onPressed: () {
              controller.acceptOrder(order);
            },
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