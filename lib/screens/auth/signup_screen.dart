import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/validators/validators.dart';
import '../../constant/app_colors.dart';
import '../../modules/contollers/auth/auth_controller.dart';
import '../widgets/custom_text_field.dart';


class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final c = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo + Title
                Align(
                  alignment: AlignmentGeometry.topLeft,

                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 120,
                  ),
                ),

                Text(
                  "welcome_title".tr, // مرحباً بك في PLEX
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "welcome_subtitle".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                // Signup Card
                Form(
                  key: c.signupKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "signup_title".tr,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "signup_subtitle".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        CustomTextField(
                          controller: c.nameController,
                          label: "name_label".tr,
                          hint: "name_hint".tr,
                          textInputAction: TextInputAction.next,
                          focusNode: c.nameFocus,
                          nextFocusNode: c.emailFocus,
                          // validator: emailValidator,
                        ),

                        // Email
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: c.emailController,
                          label: "email_label".tr,
                          hint: "email_hint".tr,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusNode: c.emailFocus,
                          nextFocusNode: c.passwordFocus,
                          validator: emailValidator,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: c.passwordController,
                          label: "password_label".tr,
                          hint: "password_hint".tr,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          focusNode: c.passwordFocus,
                          validator: passwordValidator,
                          onSubmitted: () {
                            // signup action
                            // _performSignup(nameController.text, emailController.text, passwordController.text);
                          },
                        ),
                        const SizedBox(height: 24),

                        Obx(() {
                          return ElevatedButton(
                            onPressed: c.isLoading.value ? null : () => c.signup(),
                            child: c.isLoading.value
                                ?  SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2,color: AppColors.primary,))
                                : Text("signup_btn".tr),
                          );
                        }),
                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              // back to login
                              Get.back();
                            },
                            child: Text(
                              "have_account".tr, //
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "footer_note".tr,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
