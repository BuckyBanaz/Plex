import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/driver/home/driver_home_screen.dart';
import 'package:plex_user/services/domain/service/driver/driver_location_service.dart';
import 'package:sizer/sizer.dart';

import '../../profile/profile_screen.dart';
import '../driver_rides_screens.dart';
// import '../profile/driver_profile_screen.dart';
import '../wallet/driver_wallet_screen.dart';

class DriverMainScreenController extends GetxController {
  var selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }
}


class DriverMainNavController extends GetxController {
  final currentIndex = 0.obs;
  late final DriverLocationService _locationService;

  final List<Widget> tabs = [
    const DriverHomeScreen(),
    DriverRideScreen(),
    DriverWalletScreen(),
    DriverProfileScreen(),
  ];

  final List<IconData> icons = const [
    IconlyLight.home,
    Icons.inventory_2_outlined,
    IconlyLight.wallet,
    IconlyLight.profile,
  ];

  final List<String> _labelKeys = [
    'nav_home'.tr,
    'nav_orders'.tr,
    'nav_notification'.tr,
    'nav_profile'.tr,
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize and start location service
    _locationService = Get.put(DriverLocationService(), permanent: true);
    _locationService.startLocationUpdates();
  }

  @override
  void onClose() {
    // Stop location updates when leaving driver dashboard
    _locationService.stopLocationUpdates();
    super.onClose();
  }

  String labelFor(int index) => _labelKeys[index].tr;
  void setIndex(int i) => currentIndex.value = i;
}


class DriverMainScreen extends StatelessWidget {
  const DriverMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DriverMainNavController(), permanent: true);


    return Obx(() {
      final idx = c.currentIndex.value;
      return Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: c.tabs[idx],
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(

          itemCount: c.icons.length,
          tabBuilder: (index, isActive) {
            final color = isActive ? Colors.white: Colors.white.withOpacity(0.5);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(c.icons[index], size: 22.sp, color: color),
                SizedBox(height: 0.6.h),
                // Text(
                //   c.labelFor(index),
                //   style: TextStyle(
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w600,
                //     color: color,
                //   ),
                // ),
              ],
            );
          },
          backgroundColor: AppColors.cardBg,
          activeIndex: idx,
          gapLocation: GapLocation.none,
          splashSpeedInMilliseconds: 200,
          notchSmoothness: NotchSmoothness.defaultEdge,
          leftCornerRadius: 12,
          rightCornerRadius: 12,
          height: 8.0.h,
          onTap: c.setIndex,
          elevation: 8,
        ),
      );
    });
  }
}