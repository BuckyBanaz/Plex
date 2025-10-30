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
          // optionally you can add customerId / ApplePay / GooglePay params here
        ),
      );
      print("PaymentSheet initialized successfully");

      // 2) Present PaymentSheet
      print("Presenting PaymentSheet...");
      await Stripe.instance.presentPaymentSheet();
      print("PaymentSheet presented successfully");

      // 3) On success
      print("Payment successful!");
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful')),
        );
      } else {
        Get.snackbar('Success', 'Payment successful');
      }

      // Navigate to booking confirmation
      Get.offAllNamed(AppRoutes.bookingConfirm);
      print("Navigated to booking confirmation");

    } on StripeException catch (e) {
      final msg = e.error.localizedMessage ?? 'Payment failed';
      print("StripeException caught: $msg");
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      } else {
        Get.snackbar('Error', msg);
      }
    } catch (e) {
      print("Unexpected error in Stripe Payment: $e");
      if (context != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      } else {
        Get.snackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
      print("isLoading set to false");
      print("=== Stripe Payment Ended ===");
    }
  }
}
