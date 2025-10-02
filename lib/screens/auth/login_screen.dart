import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:plex_user/routes/appRoutes.dart';
import '../../constant/app_colors.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
                    color: AppColors.textPrimary,
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
                Container(
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
                          color: AppColors.textPrimary,
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
                      Text(
                        "email_label".tr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Email
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "email_hint".tr,
                        ),
                      ),
                      const SizedBox(height: 16),
// Password
                      Text(
                        "password_label".tr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,

                        decoration: InputDecoration(
                          hintText: "password_hint".tr,
                          suffixIcon: const Icon(Icons.visibility_off),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("login_btn".tr),
                      ),
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
