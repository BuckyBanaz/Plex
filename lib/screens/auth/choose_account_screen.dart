import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:plex_user/routes/appRoutes.dart';
import '../../constant/app_colors.dart';

class ChooseAccountScreen extends StatelessWidget {
  const ChooseAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Status bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.secondary,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Logo + Title
              Column(
                children: [
                  Align(
                    alignment: AlignmentGeometry.topLeft,

                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 120,
                    ),
                  ),
                  Text(
                    "welcome_title".tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "welcome_subtitle".tr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "choose_account_title".tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "choose_account_subtitle".tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Account Type Buttons
                    _accountTypeButton(
                      icon: Icons.person_outline,
                      text: "account_individual".tr,
                      onTap: () {

                        Get.toNamed(AppRoutes.signup);
                      },
                    ),
                    const SizedBox(height: 14),
                    _accountTypeButton(
                      icon: Icons.local_shipping_outlined,
                      text: "account_shipping".tr,
                      onTap: () {
                        Get.toNamed(AppRoutes.signup);

                      },
                    ),
                    const SizedBox(height: 14),
                    _accountTypeButton(
                      icon: Icons.store_outlined,
                      text: "account_vendor".tr,
                      onTap: () {
                        Get.toNamed(AppRoutes.view);
                      },
                    ),

                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "back_to_login".tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "footer_text".tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Account Type Button
  Widget _accountTypeButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
