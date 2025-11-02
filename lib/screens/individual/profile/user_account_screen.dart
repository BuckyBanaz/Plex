import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/individual/Booking/confirm_details_screen.dart';
import 'package:plex_user/screens/individual/profile/user_profile_screen.dart';

import '../../../modules/controllers/profile/user_profile_controller.dart';
import '../../widgets/custom_button.dart';

class UserAccountScreen extends StatelessWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController c = Get.find<UserProfileController>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Account',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(CupertinoIcons.back),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          const SizedBox(height: 18),

          ProfileHeader(name: c.currentUser.value!.name),
          const SizedBox(height: 18),
          Divider(),
          const SizedBox(height: 18),

          InfoColumnItem(
              "Full Name",
              titleSize: 14,
            c.currentUser.value!.name,
            subtitleSize: 20,
          ),
          const SizedBox(height: 20),
          InfoColumnItem(
            "DOB",
            titleSize: 14,
            "12/04/1990",
            subtitleSize: 20,
          ),
          const SizedBox(height: 20),
          InfoColumnItem(
            "Mobile Phone",
            titleSize: 14,
            "(629) 7896758465",
            subtitleSize: 20,
          ),
          const SizedBox(height: 20),
          InfoColumnItem(
            "Email",
            titleSize: 14,
            c.currentUser.value!.email,
            subtitleSize: 20,
          ),
          const SizedBox(height: 20),
          InfoColumnItem(
            "Gender",
            titleSize: 14,
            "Male",
            subtitleSize: 20,
          ),

          const SizedBox(height: 30),
          CustomButton(
            onTap: ()=> c.logoutUser(context),
            padding: EdgeInsets.zero,
            widget: Center(
              child: Text(
                "logout".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          CustomButton(
            onTap: () {},
            padding: EdgeInsets.zero,
            color: AppColors.primarySwatch.shade100,
            widget: Center(
              child: Text(
                "Delete Account".tr,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
