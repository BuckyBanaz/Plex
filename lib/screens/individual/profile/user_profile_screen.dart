import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/modules/controllers/settings/user_profile_controller.dart';
import 'package:plex_user/screens/individual/profile/user_account_screen.dart';
import 'package:plex_user/screens/individual/profile/user_change_language.dart';
import 'package:plex_user/screens/individual/profile/user_help_support_screen.dart';
import 'package:plex_user/screens/individual/profile/user_reset_password_screen.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/services/domain/service/api/api_import.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController c = Get.put(UserProfileController());


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
                    children: _sampleOptions().map((opt) {
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

/// Small model for a profile option
class ProfileOption {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  ProfileOption({required this.title, required this.icon, this.onTap});
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final ImageProvider? profileImage;
  final bool isEdit;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    this.profileImage,
    this.isEdit = false, // Default 'isEdit' ko false rakha hai
    this.onEditPressed,
  });

  // Initials nikalne ka function
  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: profileImage,
              child: profileImage == null
                  ? Text(
                getInitials(name),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              )
                  : null,
            ),


            if (isEdit)
              GestureDetector(
                onTap: onEditPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Primary background color
                    shape: BoxShape.circle, // Circular shape
                    border: Border.all(
                      color: Colors.white, // White border
                      width: 2,
                    ),
                  ),
                  child:  Icon(
                    IconlyLight.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// A single option row widget
class ProfileOptionRow extends StatelessWidget {
  final ProfileOption option;
  const ProfileOptionRow({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
        child: Row(
          children: [
            // small rounded box with icon (matches orange icon in picture)
            Icon(option.icon, color: AppColors.primary, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Sample data. In real app you would load these from localization/resource files
List<ProfileOption> _sampleOptions() {
  return [
    ProfileOption(
      title: 'my_account'.tr,
      icon: Icons.account_circle,
      onTap: () {
        Get.to(UserAccountScreen());
      },
    ),
    ProfileOption(
      title: 'change_language'.tr,
      icon: Icons.translate,
      onTap: () => Get.to(UserChangeLanguageScreen()),
    ),
    ProfileOption(
      title: 'reset_password'.tr,
      icon: Icons.lock_reset,
      onTap: () => Get.to(UserResetPasswordScreen()),
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
      onTap: ()=> Get.to(UserHelpSupportScreen()),
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
