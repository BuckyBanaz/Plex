import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyRegistrationController extends GetxController {
  // Page Navigation
  final currentPage = 1.obs;
  final pageController = PageController();
  final totalSteps = 5;

  // --- Step 1: Company Information ---
  final formKeyStep1 = GlobalKey<FormState>();
  final companyNameController = TextEditingController();
  final companyNameEnController = TextEditingController();
  final commercialRegisterController = TextEditingController();
  final taxRegisterController = TextEditingController();
  final selectedBusinessType = Rx<String?>(null);
  final selectedBusinessSector = Rx<String?>(null);

  // --- Step 2: Contact Information ---
  final formKeyStep2 = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController(text: '+966512345678');
  final websiteController = TextEditingController(text: 'https://www.company.com');

  // --- Step 3: Address ---
  final formKeyStep3 = GlobalKey<FormState>();
  final selectedCountry = Rx<String?>('Saudi Arabia'); // Default for example
  final cityController = TextEditingController(text: 'Riyadh');
  final districtController = TextEditingController(text: 'Olaya');
  final streetController = TextEditingController(text: 'King Fahd Street');
  final buildingNumberController = TextEditingController(text: '1234');
  final postalCodeController = TextEditingController(text: '12345');

  // --- Step 4: Authorized Person ---
  final formKeyStep4 = GlobalKey<FormState>();
  final fullNameController = TextEditingController(text: 'Ahmed Mohammed Alsaad');
  final positionController = TextEditingController(text: 'Operations Manager');
  final authPhoneController = TextEditingController(text: '+966512345678');
  final authEmailController = TextEditingController(text: 'ahmed@company.com');

  // --- Step 5: Activity Details ---
  final formKeyStep5 = GlobalKey<FormState>();
  final selectedEmployeeCount = Rx<String?>(null);
  final selectedShipmentVolume = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initialize default values for dropdowns if needed
    // selectedCountry.value = 'Saudi Arabia';
  }

  // Next step navigation and validation
  void nextStep() {
    GlobalKey<FormState>? currentKey;
    switch (currentPage.value) {
      case 1:
        currentKey = formKeyStep1;
        break;
      case 2:
        currentKey = formKeyStep2;
        break;
      case 3:
        currentKey = formKeyStep3;
        break;
      case 4:
        currentKey = formKeyStep4;
        break;
      case 5:
        currentKey = formKeyStep5;
        break;
    }

    if (currentKey!.currentState!.validate()) {
      if (currentPage.value < totalSteps) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        currentPage.value++;
      } else {
        // Final step: Create Account
        print('Creating Account...');
        // Add final submission logic here
      }
    }
  }

  // Helper method for password validation
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field'.tr;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters'.tr;
    }
    return null;
  }

  // Helper method for email validation
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field'.tr;
    }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email address'.tr;
    }
    return null;
  }

  @override
  void onClose() {
    pageController.dispose();
    companyNameController.dispose();
    companyNameEnController.dispose();
    commercialRegisterController.dispose();
    taxRegisterController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    cityController.dispose();
    districtController.dispose();
    streetController.dispose();
    buildingNumberController.dispose();
    postalCodeController.dispose();
    fullNameController.dispose();
    positionController.dispose();
    authPhoneController.dispose();
    authEmailController.dispose();
    super.onClose();
  }
}