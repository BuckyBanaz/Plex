import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../../models/driver_order_model.dart';
import '../../../../modules/controllers/home/driver_home_controller.dart';

class NewOrderSheet extends StatelessWidget {
  final OrderModel orderData;

  const NewOrderSheet({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {

    final DriverHomeController controller = Get.find<DriverHomeController>();

    return Container(

      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

               Text(
                'newOrder'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'earnings'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${orderData.estimatedCost.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // if (orderData.isPaid)
                  Row(
                    children: [
                      Icon(
                        orderData.paymentStatus != "pending" ? Icons.check_circle : Icons.cancel,
                        color: orderData.paymentStatus != "pending"
                            ? AppColors.greenPaid
                            : AppColors.redUnpaid,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        orderData.paymentStatus != "pending" ? 'paid'.tr : 'unpaid'.tr,
                        style: TextStyle(
                          color: orderData.paymentStatus != "pending"
                              ? AppColors.greenPaid
                              : AppColors.redUnpaid,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),


              _buildAddressRow(
                title: 'pickup'.tr,
                address: '${orderData.pickupAddressLine1}, ${orderData.pickupAddressLine2}',
                distance: '...',
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Icon(
                  Icons.swap_vert,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),


              _buildAddressRow(
                title: 'delivery'.tr,
                address: '${orderData.pickup.address}',
                distance: '....',
              ),
              const SizedBox(height: 24),

              Text.rich(
                TextSpan(
                  text:'${orderData.pickup.name} - ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: orderData.pickup.phone,

                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        controller.rejectOrder(orderData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF3E0),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text(
                        'rejectOrder'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        controller.acceptOrder(orderData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text(
                        'acceptOrder'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAddressRow({
    required String title,
    required String address,
    required String distance,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          distance,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}