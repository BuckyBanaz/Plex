import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import '../../../routes/appRoutes.dart';

class StripePaymentController extends GetxController {
  var isLoading = false.obs;
  var clientSecret = ''.obs;

  Future<void> payWithStripe({
    required int amountInPaise,
    String currency = 'inr',
    BuildContext? context,
  }) async {
    print("=== Stripe Payment Started ===");
    print("Amount in paise: $amountInPaise");

    // Safety check: Agar client secret khali hai toh aage mat badho
    if (clientSecret.value.isEmpty) {
      print("❌❌❌ PAYMENT STATUS: FAILED (Client Secret is empty)");
      Get.snackbar('Error', 'Payment details are missing. Please try again.');
      return;
    }

    print("ClientSecret: ${clientSecret.value}");

    try {
      isLoading.value = true;
      print("isLoading set to true");

      // 1) Initialize PaymentSheet
      print("Initializing PaymentSheet...");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret.value,
          merchantDisplayName: 'Plex',
        ),
      );
      print("PaymentSheet initialized successfully");

      // 2) Present PaymentSheet
      print("Presenting PaymentSheet... (Waiting for user action)");
      await Stripe.instance.presentPaymentSheet();
      print("PaymentSheet presented successfully (No error thrown)");

      // 3) On success
      // Agar code yahaan tak pahuncha hai, iska matlab payment SUCCESSFUL hai
      print("✅✅✅ PAYMENT STATUS: SUCCESS ✅✅✅");

      // Snackbar dikhao
      Get.snackbar('Success', 'Payment successful');

      // Ab booking confirmation par navigate karo
      print("Navigating to booking confirmation...");
      Get.offAllNamed(AppRoutes.bookingConfirm);

    } on StripeException catch (e) {
      // 4) On Stripe Error (Fail / Cancel)
      if (e.error.code == FailureCode.Canceled) {
        // Agar user ne payment sheet ko band kar diya
        print("🔶🔶🔶 PAYMENT STATUS: CANCELED BY USER 🔶🔶🔶");
        Get.snackbar('Cancelled', 'Payment was cancelled');
      } else {
        // Agar payment fail hua (e.g., card declined)
        final msg = e.error.localizedMessage ?? 'Payment failed';
        print("❌❌❌ PAYMENT STATUS: FAILED (StripeException) ❌❌❌");
        print("Error Details: $msg");
        Get.snackbar('Error', msg);
      }

    } catch (e) {
      // 5) On Unexpected Error
      print("❌❌❌ PAYMENT STATUS: FAILED (Unexpected Error) ❌❌❌");
      print("Error Details: $e");
      Get.snackbar('Error', e.toString());

    } finally {
      // Ye hamesha chalega (success ya fail)
      isLoading.value = false;
      print("isLoading set to false");
      print("=== Stripe Payment Ended ===");
    }
  }
}