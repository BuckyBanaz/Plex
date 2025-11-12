import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/individual/home/user_home_screen.dart';
import 'package:sizer/sizer.dart';

import '../../notification/user_notification_screen.dart';
import '../../profile/profile_screen.dart';
import '../order/user_order_screen.dart';

class UserMainScreenController extends GetxController {
  var selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }
}

class UserMainNavController extends GetxController {
  final currentIndex = 0.obs;

  final List<Widget> tabs = [
    const UserHomeScreen(),
    UserOrderScreen(),
    UserNotification(),
    UserProfileScreen()
  ];

  final List<IconData> icons = const [
    IconlyLight.home,
    Icons.inventory_2_outlined,
    IconlyLight.notification,
    IconlyLight.profile,
  ];

  final List<String> _labelKeys = [
    'nav_home',
    'nav_orders',
    'nav_notification',
    'nav_profile',
  ];

  String labelFor(int index) => _labelKeys[index].tr;

  void setIndex(int i) => currentIndex.value = i;
}


class UserMainScreen extends StatelessWidget {
  const UserMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UserMainNavController(), permanent: true);

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
            final color = isActive
                ? Colors.white
                : Colors.white.withOpacity(0.5);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(c.icons[index], size: 22.sp, color: color),
                SizedBox(height: 0.6.h),
                Text(
                  c.labelFor(index),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            );
          },
          backgroundColor: AppColors.primary,
          activeIndex: idx,
          gapLocation: GapLocation.none,
          splashSpeedInMilliseconds: 200,
          notchSmoothness: NotchSmoothness.defaultEdge,
          leftCornerRadius: 18,
          rightCornerRadius: 18,
          height: 8.0.h,
          onTap: c.setIndex,
          elevation: 8,
        ),
      );
    });
  }
}
