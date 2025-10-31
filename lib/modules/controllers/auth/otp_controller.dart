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

  bool get canResend => secondsRemaining.value == 0;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  /// Start/reset the resend countdown timer
  void startTimer({int seconds = 60}) {
    // Reset
    _timer?.cancel();
    secondsRemaining.value = seconds;

    // If seconds is 0 then no need to start a timer
    if (seconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Clear OTP input
  void clearOtp() {
    otpController.clear();
  }

  /// Resend OTP API call; email must be provided
  Future<void> resendOtp(String email) async {
    if (!canResend) {
      showToast(message: 'please_wait_for_resend'.tr);
      return;
    }

    try {
      isLoading.value = true;
      await _authRepo.resendOtp(
        keyType: 'email',
        keyValue: email,
      );

      showToast(message: 'otp_resent'.tr);

      startTimer(seconds: 60);
    } catch (e, st) {

      print('resendOtp error: $e\n$st');
      showToast(message: 'server_busy_try_again'.trArgs([''])); // or fallback
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP API call; email must be provided
  Future<void> verifyOtp(String email) async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showToast(message: 'otp_required'.tr);
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
        // Navigate after success — change route if needed
        Get.offAllNamed(AppRoutes.login);
      } else {
        showToast(message: 'invalid_otp'.tr);
      }
    } catch (e, st) {
      print('verifyOtp error: $e\n$st');
      // Friendly fallback message
      showToast(message: 'server_busy_try_after_some_time'.tr);
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
