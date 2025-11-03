
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(width: double.infinity),
              Column(
                children: [

                  Image.asset(
                    'assets/images/failed.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 30.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE5CC4B),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        "Payment Unsuccessful",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    "Please try again or use a different payment method.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to support team or open chat
                      Get.snackbar(
                        "Support",
                        "Support team functionality not implemented.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text(
                      "support team",
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              // === Bottom Button ===

              CustomButton(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  onTap: () {
                // TODO: Implement "Try Again" logic
                // For now, just pop or navigate back
                // Get.back(); // Ya fir Get.to(PaymentScreen())
              } , widget: Center(
                child: Text(
                  "Try Again",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),

            ],
          ),
        ),
      ),
    );
  }
}