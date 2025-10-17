import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/home/home_screen.dart';
import 'package:sizer/sizer.dart';

class UserMainScreenController extends GetxController {
  var selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }
}

class MainScreen extends StatelessWidget {
 MainScreen({super.key});
  final UserMainScreenController controller = Get.put(UserMainScreenController());

  final List<Widget> pages = [
    const Center(child: Text("Home Screen")),
    const Center(child: Text("Order Screen")),
    const Center(child: Text("Notification Screen")),
    const Center(child: Text("Profile Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserMainScreenController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: pages[controller.selectedIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFA726), // orange background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: BottomNavigationBar(
                currentIndex: controller.selectedIndex,
                onTap: controller.changeTab,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                selectedFontSize: 13,
                unselectedFontSize: 13,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    label: 'Order',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_none),
                    label: 'Notification',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
class UserMainNavController extends GetxController {
  final currentIndex = 0.obs;

  // Keep as `final` (const भी रख सकते हो)
  final List<Widget> tabs = const [
    HomeScreen(),
    const Center(child: Text("Order Screen")),
    const Center(child: Text("Notification Screen")),
    const Center(child: Text("Profile Screen")),
  ];

  final List<IconData> icons = const [
    IconlyLight.home,
 Icons.inventory_2_outlined,
    IconlyLight.notification,
    IconlyLight.profile,
  ];

  final List<String> labels = const [
    "Home", "Orders", "Notification", "Profile"
  ];

  void setIndex(int i) => currentIndex.value = i;
}


class UserMainScreen extends StatelessWidget {
  const UserMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UserMainNavController(), permanent: true);

    final scheme = Theme.of(context).colorScheme;

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
                Text(
                  c.labels[index],
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