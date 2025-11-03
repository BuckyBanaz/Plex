import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/modules/controllers/auth/auth_controller.dart';

import 'package:plex_user/routes/appRoutes.dart';
import '../../common/validators/validators.dart';
import '../../constant/app_colors.dart';
import '../widgets/custom_text_field.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                // Logo & Title
                Align(
                  alignment: AlignmentGeometry.topLeft,

                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 120,
                  ),
                ),

                Text(
                  "welcome_title".tr, // PLEX مرحباً بك في
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "welcome_subtitle".tr, // شبكة الحلقات الأولى اللوجستية
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                // Login Card
                Form(
                  key: c.loginKey,
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
                          "login_title".tr, // مرحباً بعودتك
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "login_subtitle".tr, // سجل دخولك إلى حسابك
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(() {
                          return CustomTextField(
                            controller: c.emailController,
                            label: "email_label".tr,
                            hint: "email_hint".tr,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            focusNode: c.emailFocus,
                            nextFocusNode: c.passwordFocus,
                            validator: emailValidator,
                            errorText: c.emailError.value, // ✅ bind error text
                          );
                        }),
                        const SizedBox(height: 16),
                        Obx(() {
                          return CustomTextField(
                            controller: c.passwordController,
                            label: "password_label".tr,
                            hint: "password_hint".tr,
                            isPassword: true,
                            validator: passwordValidator,
                            textInputAction: TextInputAction.done,
                            focusNode: c.passwordFocus,
                            errorText: c.passwordError.value, // ✅ bind error text
                            onSubmitted: () => c.login(),
                          );
                        }),

                        const SizedBox(height: 24),

                        Obx(() {
                          return ElevatedButton(
                            onPressed: c.isLoading.value ? null : () => c.login(),
                            child: c.isLoading.value
                                ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 3,color: AppColors.primary,))
                                : Text("login_btn".tr),
                          );
                        }),
                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.choose);
                            },
                            child: Text(
                              "no_account".tr, // ليس لديك حساب؟ سجل الآن
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
                  "footer_note".tr, // تطبيق تجريبي - قم بإنشاء أي حساب للبدء
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
