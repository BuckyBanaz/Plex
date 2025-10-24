import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/routes/appRoutes.dart';
import '../../../common/Toast/toast.dart';
import '../../../services/domain/repository/repository_imports.dart';

class OtpController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  final otpController = TextEditingController();
  final isLoading = false.obs;
  final secondsRemaining = 60.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    secondsRemaining.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp(String email) async {
    // yaha apna resend OTP API call karo
    // Get.snackbar('Info'.tr, 'otp_resent'.tr);
    showToast(message: 'otp_resent'.tr);
    startTimer(); // reset timer
  }

  Future<void> verifyOtp(String email) async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showToast(message: 'otp_required'.tr);
      // Get.snackbar('Error'.tr, 'otp_required'.tr);
      return;
    }

    try {
      isLoading.value = true;
      final isVerified = await _authRepo.verifyOtp(
        keyType: 'email',
        keyValue: email,
        otp: otp,
      );

      if (isVerified) {
        showToast(message: 'otp_verified'.tr);
        // Get.snackbar('Success'.tr, 'otp_verified'.tr);
        Get.offAllNamed(AppRoutes.login); // OTP success → go to Home
      } else {
        showToast(message: 'invalid_otp'.tr);
        // Get.snackbar('Error'.tr, 'invalid_otp'.tr);
      }
    } catch (e) {
      showToast(message: ' Server is busy! Please try after sometimes');
      // Get.snackbar('Error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
