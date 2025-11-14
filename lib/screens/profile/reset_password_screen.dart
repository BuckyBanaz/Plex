import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';

import '../../../constant/app_colors.dart' show AppColors;
import '../../../modules/controllers/settings/profile_controller.dart';
import '../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title:  Text(
          'reset_password'.tr,
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
               Text(
                'subtitle_reset_password'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 22),

              // New Password
              CustomTextField(
                controller: controller.newPass,
                label: 'new_password_label'.tr,
                labelColor: AppColors.textPrimary,
                isPassword: true,
                focusNode: controller.newPassFocus,
                nextFocusNode: controller.confirmPassFocus,
                textInputAction: TextInputAction.next,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'enter_password'.tr;
                  if (v.trim().length < 8)
                    return 'password_length'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password
              CustomTextField(
                controller: controller.confirmPass,
                label: 'confirm_password_label'.tr,
                labelColor: AppColors.textPrimary,
                isPassword: true,
                focusNode: controller.confirmPassFocus,
                textInputAction: TextInputAction.done,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),

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
                  if (v == null || v.isEmpty) return 'confirm_password';
                  if (v.trim().length < 8)
                    return 'password_length'.tr;
                  return null;
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      controller.showForgotPasswordDialog(context),
                  style: TextButton.styleFrom(padding: EdgeInsets.only(top: 8)),
                  child:  Text(
                    'forgot_password_button'.tr,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Obx(() => CustomButton(
                onTap: () => controller.resetPassword(context),
                widget:    controller.loading.value
                    ? Center(child: CircularProgressIndicator(color: AppColors.textColor,)) :Center(
                  child: Text(
                    'reset_button'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 6),

               Text(
                'instructions'.tr,
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
