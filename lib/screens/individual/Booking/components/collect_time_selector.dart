import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constant/app_colors.dart';
import '../../../../modules/controllers/booking/booking_controller.dart';

class CollectTimeSelector extends StatelessWidget {
  const CollectTimeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();

    return Obx(() {
      return Row(
        children: [
          // Immediate Card
          Expanded(
            child: GestureDetector(
              onTap: () => c.selectTime(0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.selectedTime.value == 0
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                           "immediate".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(
                          c.selectedTime.value == 0
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                     Text(
                       "collect_time_range".tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                     Text(
                       "delivery_to_receiver".tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Schedule Card
          Expanded(
            child: GestureDetector(
              onTap: () => c.selectTime(1),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.selectedTime.value == 1
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                           "schedule".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(
                          c.selectedTime.value == 1
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                     Text(
                       "choose_available_time".tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children:  [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.black45,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "plan_2_day_ahead".tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
