import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/profile/components/profile_option.dart';
import '../../../modules/controllers/settings/profile_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/helpers.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController c = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('my_account'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.back)),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // decide whether driver or individual
        final isDriver = c.currentDriver.value != null || (c.db.userType == 'driver');
        final name = isDriver ? (c.currentDriver.value?.name ?? '-') : (c.currentUser.value?.name ?? '-');

        // common fields (safe access)
        final email = isDriver ? (c.currentDriver.value?.email ?? '-') : (c.currentUser.value?.email ?? '-');
        final mobile = isDriver ? (c.currentDriver.value?.mobile ?? '-') : (c.currentUser.value?.mobile ?? '-');
        // final dob = isDriver ? (c.currentDriver.value?.dob ?? '-') : (c.currentUser.value?.dob ?? '12/04/1990'); // replace default as needed
        //
        // // driver specific
        // final vehicleNumber = c.currentDriver.value?.vehicleNumber;
        // final rating = c.currentDriver.value?.rating;
   final dob = '12/04/1990'; // replace default as needed

        // driver specific
        final vehicleNumber = c.currentDriver.value?.id.toString();
        final rating = c.currentDriver.value?.id;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 18),

            // Profile header - pass driver flag and driver specific data if available
            ProfileHeader(
              name: name,
              isEdit: true,

              rating: 20,
              // profileImage: ... // pass if available
              onEditPressed: () {
                // open edit profile
              },
            ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 18),

            // Info items - show different items based on user type
            InfoColumnItem("full_name_label".tr, titleSize: 14, name, subtitleSize: 20),
            const SizedBox(height: 20),

            InfoColumnItem("dob".tr, titleSize: 14, dob, subtitleSize: 20),
            const SizedBox(height: 20),

            InfoColumnItem("mobile_number".tr, titleSize: 14, mobile, subtitleSize: 20),
            const SizedBox(height: 20),

            InfoColumnItem("email_label".tr, titleSize: 14, email, subtitleSize: 20),
            const SizedBox(height: 20),

            if (!isDriver) ...[
              InfoColumnItem("gender".tr, titleSize: 14, "Male", subtitleSize: 20),
              const SizedBox(height: 20),
            ],

            // driver extra info
            if (isDriver) ...[
              InfoColumnItem("vehicle_number".tr, titleSize: 14, vehicleNumber ?? 'N/A', subtitleSize: 20),
              const SizedBox(height: 20),
              InfoColumnItem("rating".tr, titleSize: 14, rating != null ? rating.toString() : '-', subtitleSize: 20),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 30),

            CustomButton(
              onTap: () => c.logoutUser(context),
              padding: EdgeInsets.zero,
              widget: const Center(
                child: Text("logout", style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),

            CustomButton(
              onTap: () {},
              padding: EdgeInsets.zero,
              color: AppColors.primarySwatch.shade100,
              widget: const Center(
                child: Text("delete_account", style: TextStyle(color: Colors.grey, fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      }),
    );
  }
}
