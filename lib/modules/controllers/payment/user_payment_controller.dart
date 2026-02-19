import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/modules/controllers/payment/stripe_payment_controller.dart';

import '../../../common/Toast/toast.dart';
import '../../../routes/appRoutes.dart';
import '../../../services/paypal/paypal_webview.dart';
import '../booking/booking_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPaymentController extends GetxController {
  late PageController pageController;
  final RxInt currentPage = 1.obs;
  var isLoading = false.obs;
  final BookingController bookingController = Get.find<BookingController>();
  final StripePaymentController stripeController = Get.put(StripePaymentController());

  final RxString selectedPaymentOption =
      "PayPal".obs; // default to PayPal, or empty

  final RxList<Map<String, String>> cards = <Map<String, String>>[
    {
      'cardHolder': 'Parikshit Verma',
      'cardNumber': '1234 5678 9012 3456',
      'expiryDate': '12/27',
      'logo': 'assets/images/visa.png',
      'color': '0xFF4A00E0', // Purple
    },
    {
      'cardHolder': 'Vipin Jain',
      'cardNumber': '5282 3456 7890 1289',
      'expiryDate': '09/25',
      'logo': 'assets/images/visa.png',
      'color': '0xFFF39C12', // Gold/Orange from image
    },
    {
      'cardHolder': 'Bucky Banaz',
      'cardNumber': '9876 5432 1098 7654',
      'expiryDate': '06/26',
      'logo': 'assets/images/visa.png',
      'color': '0xFFD35400', // Red/Orange
    },
  ].obs;

  final List<Map<String, dynamic>> paymentOptions = [
    // {'name': 'UPI', 'logo': 'assets/icons/upi.png', 'isAsset': true},
    // {'name': 'PayPal', 'logo': 'assets/icons/paypal.png', 'isAsset': true},
    // {'name': 'Google Pay', 'logo': 'assets/icons/gpay.png', 'isAsset': true},
    {'name': 'Stripe', 'logo': 'assets/icons/stripe.png', 'isAsset': true},
    {'name': 'COD', 'logo': Icons.money, 'isAsset': false},
    {
      'name': 'Net Banking',
      'logo': Icons.laptop_chromebook_outlined,
      'isAsset': false,
    },
  ];

  void selectPaymentOption(String optionName) {
    selectedPaymentOption.value = optionName;
  }

  final GlobalKey<FormState> addCardFormKey = GlobalKey<FormState>();

  late TextEditingController nameOnCardController;
  late TextEditingController cardNumberController;
  late TextEditingController expiryDateController;
  late TextEditingController cvvController;

  void addCard() {
    if (addCardFormKey.currentState!.validate()) {
      final newCard = {
        'cardHolder': nameOnCardController.text,
        'cardNumber': cardNumberController.text,
        'expiryDate': expiryDateController.text,
        'logo': 'assets/images/visa.png',
        'color': '0xFF4A00E0',
      };

      // cards.add(newCard);

      nameOnCardController.clear();
      cardNumberController.clear();
      expiryDateController.clear();
      cvvController.clear();

      Get.back(closeOverlays: false);
showToast(message: "success_card_added".tr);
      // Get.snackbar(
      //   'Success',
      //   'New card added successfully!',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }
  }

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(
      viewportFraction: 0.8,
      initialPage: currentPage.value,
    );
    pageController.addListener(() {
      int next = pageController.page!.round();
      if (currentPage.value != next) {
        currentPage.value = next;
      }
    });

    nameOnCardController = TextEditingController();
    cardNumberController = TextEditingController();
    expiryDateController = TextEditingController();
    cvvController = TextEditingController();
  }
  Future<void> proceedPayment() async {
    print("proceedPayment called"); // function entered

    final rawSelected = selectedPaymentOption.value;
    final selected = rawSelected.trim();
    print("Selected payment option: $selected");

    // helper to normalize the payment method for backend
    String _normalizePaymentMethod(String s) {
      final lower = s.toLowerCase();
      if (lower.contains('stripe') || lower.contains('stipe')) return 'stripe';
      if (lower.contains('paypal')) return 'paypal';
      if (lower.contains('upi')) return 'upi';
      if (lower.contains('google')) return 'googlepay';
      if (lower.contains('cod') || lower.contains('cash')) return 'cod';
      if (lower.contains('net')) return 'net_banking';
      return lower; // fallback
    }

    final normalizedMethod = _normalizePaymentMethod(selected);

    try {
      isLoading.value = true;
      print("isLoading set to true");

      // If shipment not yet created on server (no clientSecret and no intent id), create it now
      if (bookingController.shipmentClientSecret.value.isEmpty &&
          bookingController.stripePaymentIntentId.value.isEmpty) {
        print("No shipment/payment initialized yet. Creating shipment with paymentMethod: $normalizedMethod");

        final res = await bookingController.createShipmentAndPreparePayment(paymentMethod: normalizedMethod);

        if (res == null) {
          showToast(message: "Failed to create shipment. Try again.");
          isLoading.value = false;
          return;
        }

        // If API returned no clientSecret and payment is non-Stripe, treat accordingly
        if (bookingController.shipmentClientSecret.value.isEmpty) {
          // COD (server handled)
          if (normalizedMethod == 'cod') {
            showToast(message: "Order placed with Cash on Delivery");
            Get.offAllNamed(AppRoutes.bookingConfirm);
            isLoading.value = false;
            return;
          }

          // PayPal / UPI may return a redirect URL in response; try to use it
          if (normalizedMethod == 'paypal') {
            final payUrl = res['paymentUrl']?.toString() ?? res['paypalUrl']?.toString() ?? '';
            if (payUrl.isNotEmpty) {
              // open PayPal webview if you have one
              Get.to(() => PayPalWebView(url: payUrl));
              isLoading.value = false;
              return;
            } else {
              showToast(message: "Proceed to PayPal (implement webview flow).");
              isLoading.value = false;
              return;
            }
          }

          // UPI / GooglePay: backend might return a deep link or UPI params
          if (normalizedMethod == 'upi' || normalizedMethod == 'googlepay') {
            final upiUrl = res['paymentUrl']?.toString() ?? res['upiUrl']?.toString() ?? '';
            if (upiUrl.isNotEmpty) {
              // open url launcher
              if (await canLaunch(upiUrl)) {
                await launch(upiUrl);
              } else {
                showToast(message: "Unable to open UPI app");
              }
              isLoading.value = false;
              return;
            } else {
              showToast(message: "UPI/GooglePay flow not implemented");
              isLoading.value = false;
              return;
            }
          }

          // fallback if backend handled payment and returned nothing for client secret
          showToast(message: "Payment flow handled server-side or unsupported method.");
          isLoading.value = false;
          return;
        }
      }

      // At this point, if we have a clientSecret and selected is Stripe -> perform Stripe flow
      if (normalizedMethod == "stripe") {
        final clientSecret = bookingController.shipmentClientSecret.value;
        final paymentIntentId = bookingController.stripePaymentIntentId.value;

        if (clientSecret.isEmpty) {
          showToast(message: "Payment not initialized properly");
          isLoading.value = false;
          return;
        }

        stripeController.clientSecret.value = clientSecret;
        stripeController.paymentIntentId.value = paymentIntentId;
        print("Stripe controller clientSecret set: ${stripeController.clientSecret.value}");
        print("Stripe controller paymentIntentId set: ${stripeController.paymentIntentId.value}");

        final amountInPaise = (bookingController.amountPayable * 100).toInt();
        print("Amount in paise: $amountInPaise");

        await stripeController.payWithStripe(
          amountInPaise: amountInPaise,
          context: Get.context,
        );

        print("Stripe Payment flow completed (check logs for success/failure).");
        // Don't set isLoading to false here - Stripe controller handles it
        // If payment was successful, navigation happens in payWithStripe
        // If payment was cancelled/failed, Stripe controller sets isLoading = false
        isLoading.value = false;
        return;
      }

      // If we reach here, payment method wasn't stripe and may already have been handled above
      if (normalizedMethod == 'cod') {
        showToast(message: "Order placed with Cash on Delivery");
        Get.offAllNamed(AppRoutes.bookingConfirm);
        return;
      }

      // Unimplemented methods default handler
      showToast(message: "Selected payment method ($selected) is not implemented yet.");
    } catch (e) {
      print("Error in proceedPayment: $e");
      showToast(message: "Payment failed: $e");
    } finally {
      isLoading.value = false;
      print("isLoading set to false");
    }
  }


  // Future<void> proceedPayment() async {
  //   print("proceedPayment called"); // function entered
  //
  //   if (selectedPaymentOption.value != "Stipe") {
  //     print("Selected payment option is not Stripe: ${selectedPaymentOption.value}");
  //     showToast(message: "This is not valid, you can use Stripe");
  //     return;
  //   }
  //
  //   try {
  //     isLoading.value = true;
  //     print("isLoading set to true");
  //
  //     // Booking se shipment create ho chuka hai, uska clientSecret le lo
  //     final clientSecret = bookingController.shipmentClientSecret.value;
  //     print("ClientSecret from bookingController: $clientSecret");
  //     final paymentIntentId = bookingController.stripePaymentIntentId.value;
  //     print("paymentIntentId from bookingController: $paymentIntentId");
  //
  //     if (clientSecret.isEmpty) {
  //       print("ClientSecret is empty!");
  //       showToast(message: "Payment not initialized properly");
  //       isLoading.value = false;
  //       return;
  //     }
  //
  //     stripeController.clientSecret.value = clientSecret;
  //     print("Stripe controller clientSecret set: ${stripeController.clientSecret.value}");
  //     stripeController.paymentIntentId.value = paymentIntentId;
  //     print("Stripe controller paymentIntentId set: ${stripeController.paymentIntentId.value}");
  //
  //     final amountInPaise = (bookingController.amountPayable * 100).toInt();
  //     print("Amount in paise: $amountInPaise");
  //
  //     await stripeController.payWithStripe(
  //
  //       amountInPaise: amountInPaise,
  //       context: Get.context,
  //     );
  //
  //     print("Stripe Payment completed");
  //
  //   } catch (e) {
  //     print("Error in proceedPayment: $e");
  //     showToast(message: "Payment failed: $e");
  //   } finally {
  //     isLoading.value = false;
  //     print("isLoading set to false");
  //   }
  // }


  @override
  void onClose() {
    pageController.dispose();

    nameOnCardController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.onClose();
  }
}
