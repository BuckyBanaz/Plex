import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/modules/controllers/home/driver_home_controller.dart';
import 'package:plex_user/routes/appRoutes.dart';
import '../../../constant/app_colors.dart';
import '../../individual/home/components/top_bar.dart' show TopBar;
import 'components/delivery_notification_card.dart';
import 'components/recent_history_list.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final DriverHomeController controller = Get.put(DriverHomeController());
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Obx(
        () {

          return controller.isLoading.value ? Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ):SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: h * 0.30,
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
                            showLanguageButton: false,
                            iconButton:IconButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.driverNotification),
                              icon: Icon(
                                IconlyLight.notification,
                                color: AppColors.textColor,
                                size: 28,
                              ),
                            ),
                            showIcon: true,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),

                          const SizedBox(height: 35),

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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.currentDriver.value?.name ?? "driver".tr,
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 16,
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children:  [
                                        TextSpan(
                                          text: controller.currentDriver.value?.name ?? 'PLEX1080'.tr,
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 14,
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children:  [
                                        TextSpan(
                                          text: controller.currentDriver.value?.vehicle?.licenseNo ?? 'RJ14 2025'.tr,
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 14,
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

                          const Spacer(),

                          Text(
                            'myEarnings'.tr,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '\$ 0.00',
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                      Positioned.directional(
                        textDirection: Directionality.of(context), // This line is important
                        end: 0, // 'end' will be 'right' in LTR and 'left' in RTL
                        bottom: -10,
                        child: Image.asset(
                          'assets/images/driver.png',
                          height: h * 0.12,
                          fit: BoxFit.contain,
                            matchTextDirection: true
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
                              Text(
                                '${'status'.tr} - ${isOnline ? 'online'.tr : 'offline'.tr}',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'openToAnyDelivery'.tr,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () => setState(() => isOnline = !isOnline),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 50,
                            height: 26,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.primary
                                  : AppColors.primarySwatch.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Align(
                              alignment: isOnline
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
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
                        ),
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
                          onViewDetails: () =>
                              Get.toNamed(AppRoutes.driverDeliveryOrder),
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
