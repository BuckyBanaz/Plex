import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../constant/app_colors.dart';
import '../../modules/controllers/auth/otp_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(OtpController());

    // Get email from arguments
    final email = Get.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Align(
                alignment: AlignmentGeometry.topLeft,

                child: Image.asset(
                  "assets/images/logo.png",
                  width: 120,
                ),
              ),
              Text(
                'otp_title'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'otp_subtitle'.trParams({'email': email}),
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // OTP FIELD
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: c.otpController,
                keyboardType: TextInputType.number,
                autoFocus: true,
                animationType: AnimationType.fade,
                backgroundColor: Colors.transparent,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  activeFillColor: AppColors.cardBg,
                  inactiveFillColor: AppColors.secondary,
                  selectedFillColor: AppColors.cardBg,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  inactiveColor: AppColors.textSecondary,
                ),
                enableActiveFill: true,
                onCompleted: (value) => c.verifyOtp(email),
                onChanged: (value) {},
                autoDismissKeyboard: true,
                useHapticFeedback: true,
                autoDisposeControllers: false,
              ),

              const SizedBox(height: 16),

              // Timer / Resend
              Obx(() {
                if (c.secondsRemaining.value > 0) {
                  return Text(
                    '${'resend_in'.tr} ${c.secondsRemaining.value}s',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                } else {
                  return TextButton(
                    onPressed: () => c.resendOtp(email),
                    child: Text(
                      'resend_otp'.tr,
                      style: TextStyle(color: AppColors.primary),
                    ),
                  );
                }
              }),

              const SizedBox(height: 24),

              // Verify Button
              Obx(() {
                return ElevatedButton(
                  onPressed:
                  c.isLoading.value ? null : () => c.verifyOtp(email),
                  child: c.isLoading.value
                      ?  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,color: AppColors.primary,),
                  )
                      : Text('verify_btn'.tr),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
