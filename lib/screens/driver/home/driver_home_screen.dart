import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:sizer/sizer.dart';
import 'package:plex_user/modules/controllers/home/driver_home_controller.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/screens/order/driver_job_complete.dart';
import '../../../constant/app_colors.dart';
import '../../individual/home/components/top_bar.dart' show TopBar;
import 'components/delivery_notification_card.dart';
import 'components/recent_history_list.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DriverHomeController controller = Get.put(DriverHomeController());

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Obx(
            () {
          return controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
              : SafeArea(
            bottom: false,
            child: Column(
              children: [
                // use sizer units instead of MediaQuery
                Container(
                  width: double.infinity,
                  height: 28.5.h, // reduced slightly from 30% to avoid overflow
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TopBar(
                            titleColor: AppColors.textColor,
                            subtitleColor: AppColors.textColor,
                            showIcon: true,
                            iconButton: IconButton(
                              // onPressed: () => Get.toNamed(AppRoutes.driverNotification),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DriverJobCompleteScreen(
                                      amount: 125.50,
                                      paymentMethod: 'Online',
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                IconlyLight.notification,
                                color: AppColors.textColor,
                                size: 28,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                          SizedBox(height: 3.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'partner'.tr,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.currentDriver.value?.name ?? "driver".tr,
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: 'driverId'.tr,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: controller.currentDriver.value?.id.toString() ?? 'PLEX1080'.tr,
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      text: 'vehicleNo'.tr,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'RJ14 2025'.tr,
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'myEarnings'.tr,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.6.h),
                          Text(
                            '\$ 0.00',
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 1.2.h),
                        ],
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        end: 0,
                        bottom: -1.2.h, // less negative to avoid overflow
                        child: Image.asset(
                          'assets/images/driver.png',
                          height: 10.5.h, // slightly smaller image
                          fit: BoxFit.contain,
                          matchTextDirection: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bind status text to controller's isOnline
                              Obx(() => Text(
                                '${'status'.tr} - ${controller.isOnline.value ? 'online'.tr : 'offline'.tr}',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              )),
                              const SizedBox(height: 2),
                              Text(
                                'openToAnyDelivery'.tr,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Use GestureDetector to call controller.toggleOnlineStatus
                        Obx(() => GestureDetector(
                          onTap: () => controller.toggleOnlineStatus(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 50,
                            height: 26,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: controller.isOnline.value
                                  ? AppColors.primary
                                  : AppColors.primarySwatch.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Align(
                              alignment: controller.isOnline.value ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.textColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.textColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DeliveryNotificationCard(
                          deliveryCount: controller.orders.length,
                          onViewDetails: () => Get.toNamed(AppRoutes.driverDeliveryOrder),
                        ),
                        RecentHistoryList(controller: controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
