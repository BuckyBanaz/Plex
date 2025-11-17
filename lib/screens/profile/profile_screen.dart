import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/modules/controllers/settings/profile_controller.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/screens/profile/reset_password_screen.dart';


import 'account_screen.dart';
import 'change_language.dart';
import 'components/profile_option.dart';
import 'help_support_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController c = Get.put(ProfileController());


    // Use SafeArea and center card with top padding similar to image
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "nav_profile".tr,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(
        () => c.isLoading.value
            ? CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              )
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  const SizedBox(height: 18),

                  ProfileHeader(name: c.currentUser.value!.name),
                  const SizedBox(height: 18),

                  Column(
                    children: userOptions().map((opt) {
                      return Column(children: [ProfileOptionRow(option: opt)]);
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // CustomButton(
                  //   onTap: ()=> c.logoutUser(context),
                  //   padding: EdgeInsets.all(10),
                  //   widget: Center(
                  //     child: Text(
                  //       "logout".tr,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 18.0,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
      ),
    );
  }
}


class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController c = Get.put(ProfileController());


    // Use SafeArea and center card with top padding similar to image
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "nav_profile".tr,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(
            () => c.isLoading.value
            ? CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        )
            : ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            const SizedBox(height: 18),

          Center(
            child: ProfileHeader(
                name: c.currentDriver.value!.name,
                isDriver: true,
              driverId: "RJ144567",
                // vehicleNumber: c.currentDriver.value!.id.toString(),
                rating: 4.8,
              ),
          ),

            const SizedBox(height: 18),

            Column(
              children: driverOptions().map((opt) {
                return Column(children: [ProfileOptionRow(option: opt)]);
              }).toList(),
            ),
            const SizedBox(height: 20),

            // CustomButton(
            //   onTap: ()=> c.logoutUser(context),
            //   padding: EdgeInsets.all(10),
            //   widget: Center(
            //     child: Text(
            //       "logout".tr,
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 18.0,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}




/// Sample data. In real app you would load these from localization/resource files
List<ProfileOption> userOptions() {
  return [
    ProfileOption(
      title: 'my_account'.tr,
      icon: Icons.account_circle,
      onTap: () {
        Get.to(AccountScreen());
      },
    ),
    ProfileOption(
      title: 'change_language'.tr,
      icon: Icons.translate,
      onTap: () => Get.to(ChangeLanguageScreen()),
    ),
    ProfileOption(
      title: 'reset_password'.tr,
      icon: Icons.lock_reset,
      onTap: () => Get.to(ResetPasswordScreen()),
    ),
    ProfileOption(title: 'people_and_sharing'.tr, icon: Icons.share, onTap: () {}),
    ProfileOption( title: 'terms_of_use'.tr, icon: Icons.description, onTap: () {}),
    ProfileOption(
      title: 'privacy_policy'.tr,
      icon: Icons.privacy_tip,
      onTap: () {},
    ),
    ProfileOption(
      title: 'help_and_support'.tr,
      icon: Icons.help_outline,
      onTap: ()=> Get.to(HelpSupportScreen()),
    ),
    ProfileOption(title: 'contact_us'.tr, icon: Icons.phone_in_talk, onTap: () {}),
  ];
}
List<ProfileOption> driverOptions() {
  return [
    ProfileOption(
      title: 'my_account'.tr,
      icon: IconlyLight.profile,
      onTap: () {
        Get.to(AccountScreen());
      },
    ),
    ProfileOption(
      title: 'My Rides'.tr,
      icon: IconlyLight.bookmark,
      onTap: ()=> Get.toNamed(AppRoutes.driverRides,arguments: "navigation"),
    ),
    ProfileOption(
      title: 'Scheduled Rides'.tr,
      icon: IconlyLight.calendar,
      onTap:() {},
    ),
    ProfileOption(
      title: 'My Wallet'.tr,
      icon: IconlyLight.wallet,
      onTap: () {},
    ),
    ProfileOption(
      title: 'change_language'.tr,
      icon: Icons.translate,
      onTap: () => Get.to(ChangeLanguageScreen()),
    ),
    ProfileOption(
      title: 'reset_password'.tr,
      icon: Icons.lock_reset,
      onTap: () => Get.to(ResetPasswordScreen()),
    ),
    ProfileOption(title: 'people_and_sharing'.tr, icon: Icons.share, onTap: () {}),
    ProfileOption( title: 'terms_of_use'.tr, icon: IconlyLight.paper, onTap: () {}),
    ProfileOption(
      title: 'privacy_policy'.tr,
      icon: IconlyLight.info_circle,
      onTap: () {},
    ),
    ProfileOption(
      title: 'help_and_support'.tr,
      icon: Icons.help_outline,
      onTap: ()=> Get.to(HelpSupportScreen()),
    ),
    ProfileOption(title: 'contact_us'.tr, icon: Icons.phone_in_talk, onTap: () {}),
  ];
}

// // Ek stateful widget jo 'isEdit' state aur 'profileImage' ko manage karega
// class ProfilePageDemo extends StatefulWidget {
//   const ProfilePageDemo({super.key});
//
//   @override
//   State<ProfilePageDemo> createState() => _ProfilePageDemoState();
// }
//
// class _ProfilePageDemoState extends State<ProfilePageDemo> {
//   // State variables
//   bool _isEditing = false;
//   ImageProvider? _profileImage;
//
//   // Edit button press karne par ye function call hoga
//   Future<void> _onEditProfilePressed() async {
//     // Yahaan par aap image picker ka logic likh sakte hain
//     // Niche diye gaye code ko uncomment karein aur 'image_picker' package add karein
//     /*
//     try {
//       final picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//       if (image != null) {
//         setState(() {
//           _profileImage = FileImage(File(image.path));
//         });
//       }
//     } catch (e) {
//       print("Image picker error: $e");
//     }
//     */
//
//     // --- Demo ke liye Placeholder Image ---
//     // Upar wala code comment karke, demo ke liye hum ek network image set kar rahe hain
//     // Taki aap functionality test kar sakein.
//     print("Edit button pressed! Simulating image pick.");
//     setState(() {
//       // Ek placeholder image load kar rahe hain
//       _profileImage = const NetworkImage(
//           'https://placehold.co/120x120/E0E0E0/363636?text=New\nImage');
//     });
//     // --- Demo code end ---
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile Demo'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: ProfileHeader(
//             name: "Parikshit Verma",
//             isEdit: _isEditing, // State se 'isEdit' pass kiya
//             profileImage: _profileImage, // State se 'profileImage' pass kiya
//             onEditPressed:
//             _onEditProfilePressed, // Edit press ka function pass kiya
//           ),
//         ),
//       ),
//       // Ye button 'isEdit' state ko toggle karega
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _isEditing = !_isEditing; // Toggle editing mode
//           });
//         },
//         child: Icon(
//           _isEditing ? Icons.check : Icons.edit_note,
//         ),
//       ),
//     );
//   }
// }
