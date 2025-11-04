import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/common/validators/validators.dart';
import 'package:plex_user/modules/controllers/auth/auth_controller.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';

import '../../constant/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();


  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'forgot_password'.tr,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'enter_email_instructions'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a responsive paddings
    final horizontalPadding = MediaQuery.of(context).size.width > 600
        ? 120.0
        : 20.0;
    final controller = Get.put(AuthController());
    return Obx(()=> Scaffold(
      appBar: AppBar(
        title: Text('forgot_password'.tr),
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              Form(
                key: controller.forgotPasswordKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: "email_label".tr,
                      hint: "email_hint".tr,
                      labelColor: AppColors.textPrimary,
                      hintColor: AppColors.textGrey,
                      validator: emailValidator,
                      errorText: controller.emailError.value,


                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomButton(
                      onTap: () {


                        controller.submitForgotPassword();
                      },
                      widget: Center(
                        child: controller.isLoading.value
                            ?  CircularProgressIndicator(color: AppColors.textColor,
                          strokeWidth: 2,
                        )
                            : Text(
                          'send_reset_link'.tr,
                          style: TextStyle(color: AppColors.textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
