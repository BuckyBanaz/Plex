import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserPaymentController extends GetxController {

  late PageController pageController;
  final RxInt currentPage = 1.obs;
  final RxList<Map<String, String>> cards = <Map<String, String>>[
    {
      'cardHolder': 'Parikshit Verma',
      'cardNumber': '1234 5678 9012 3456',
      'expiryDate': '12/27',
      'logo': 'assets/images/visa.png',
      'color': '0xFF4A00E0' // Purple
    },
    {
      'cardHolder': 'Vipin Jain',
      'cardNumber': '5282 3456 7890 1289',
      'expiryDate': '09/25',
      'logo': 'assets/images/visa.png',
      'color': '0xFFF39C12' // Gold/Orange from image
    },
    {
      'cardHolder': 'Bucky Banaz',
      'cardNumber': '9876 5432 1098 7654',
      'expiryDate': '06/26',
      'logo': 'assets/images/visa.png',
      'color': '0xFFD35400' // Red/Orange
    },
  ].obs;


  final List<Map<String, dynamic>> paymentOptions = [
    {'name': 'UPI', 'logo': 'assets/icons/upi.png', 'isAsset': true},
    {'name': 'PayPal', 'logo': 'assets/icons/paypal.png', 'isAsset': true},
    {'name': 'Google Pay', 'logo': 'assets/icons/gpay.png', 'isAsset': true},
    {'name': 'Net Banking', 'logo': Icons.laptop_chromebook_outlined, 'isAsset': false},
  ];


  final RxString selectedPaymentOption = "".obs;


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