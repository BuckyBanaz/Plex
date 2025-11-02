import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/modules/controllers/profile/user_profile_controller.dart';
import 'package:plex_user/screens/individual/profile/user_account_screen.dart';
import 'package:plex_user/screens/individual/profile/user_change_language.dart';
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

/// Header widget showing avatar and name
class ProfileHeader extends StatelessWidget {
  final String name;
  const ProfileHeader({super.key, required this.name});

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
        // Grey circular avatar with initials
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Text(
            getInitials(name),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
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
      title: 'My Account',
      icon: Icons.account_circle,
      onTap: () {
        Get.to(UserAccountScreen());
      },
    ),
    ProfileOption(
      title: 'Change Language',
      icon: Icons.translate,
      onTap: () => Get.to(UserChangeLanguageScreen()),
    ),
    ProfileOption(
      title: 'Reset Password',
      icon: Icons.lock_reset,
      onTap: () => Get.to(UserResetPasswordScreen()),
    ),
    ProfileOption(title: 'People and Sharing', icon: Icons.share, onTap: () {}),
    ProfileOption(title: 'Terms of Use', icon: Icons.description, onTap: () {}),
    ProfileOption(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip,
      onTap: () {},
    ),
    ProfileOption(
      title: 'Help & Support',
      icon: Icons.help_outline,
      onTap: () {},
    ),
    ProfileOption(title: 'Contact us', icon: Icons.phone_in_talk, onTap: () {}),
  ];
}
