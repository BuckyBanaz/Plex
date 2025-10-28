import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    {'name': 'UPI', 'logo': 'assets/icons/upi.png', 'isAsset': true},
    {'name': 'PayPal', 'logo': 'assets/icons/paypal.png', 'isAsset': true},
    {'name': 'Google Pay', 'logo': 'assets/icons/gpay.png', 'isAsset': true},
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

      Get.back();

      Get.snackbar(
        'Success',
        'New card added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  // Future<void> proceedPayment() async {
  //   final selected = selectedPaymentOption.value.trim().toLowerCase();
  //
  //   if (selected == 'paypal') {
  //     final url = bookingController.paypalApproveLink.value;
  //     if (url.isEmpty) {
  //       showToast(message: "No PayPal link found. Please try again.");
  //       return;
  //     }
  //     final uri = Uri.tryParse(url);
  //     if (uri == null) {
  //       showToast(message: "Invalid PayPal URL.");
  //       return;
  //     }
  //
  //     try {
  //       if (await canLaunchUrl(uri)) {
  //         final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  //         if (opened) return; // Payment in external app
  //       }
  //
  //       // Fallback: open in-app WebView
  //       final result = await Get.to(() => PayPalWebView(url: uri.toString()));
  //       if (result == 'success') {
  //         showToast(message: "Payment successful!");
  //         Get.offAllNamed(AppRoutes.bookingConfirm);
  //       } else if (result == 'cancel') {
  //         showToast(message: "Payment cancelled.");
  //       }
  //     } catch (e) {
  //       debugPrint('Error launching PayPal: $e');
  //       showToast(message: "Cannot open PayPal. Opening in-app.");
  //       final result = await Get.to(() => PayPalWebView(url: uri.toString()));
  //       if (result == 'success') Get.offAllNamed(AppRoutes.bookingConfirm);
  //     }
  //   } else {
  //     showToast(message: "This payment method is not supported. Please use PayPal.");
  //   }
  // }

  Future<void> proceedPayment() async {
    Get.dialog(
      AlertDialog(
        title: const Text("Processing Payment"),
        content: const Text("Please wait..."),
      ),
    );

    // Wait 2 seconds and then navigate
    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // close dialog
      Get.offAllNamed(AppRoutes.bookingConfirm); // navigate to confirmation
    });
  }

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
