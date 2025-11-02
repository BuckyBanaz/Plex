import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';

import '../../../constant/app_colors.dart' show AppColors;
import '../../../modules/controllers/profile/user_profile_controller.dart';
import '../../widgets/custom_text_field.dart';

class UserResetPasswordScreen extends StatelessWidget {
  const UserResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 6),
              const Text(
                'Create a new password for your account',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 22),

              // New Password
              CustomTextField(
                controller: controller.newPass,
                label: 'New Password',
                labelColor: AppColors.textPrimary,
                isPassword: true,
                focusNode: controller.newPassFocus,
                nextFocusNode: controller.confirmPassFocus,
                textInputAction: TextInputAction.next,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter password';
                  if (v.trim().length < 8)
                    return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password
              CustomTextField(
                controller: controller.confirmPass,
                label: 'Confirm Password',
                labelColor: AppColors.textPrimary,
                isPassword: true,
                focusNode: controller.confirmPassFocus,
                textInputAction: TextInputAction.done,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                ),
                onSubmitted: () => controller.resetPassword(context),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm password';
                  if (v.trim().length < 8)
                    return 'Password must be at least 8 characters';
                  return null;
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      controller.showForgotPasswordDialog(context),
                  style: TextButton.styleFrom(padding: EdgeInsets.only(top: 8)),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Obx(() => controller.loading.value
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                onTap: () => controller.resetPassword(context),
                widget: const Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 6),

              const Text(
                'Your password should be at least 8 characters long and include a mix of letters and numbers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
