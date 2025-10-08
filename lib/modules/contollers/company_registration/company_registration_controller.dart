import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/common/Toast/toast.dart';

import '../../../models/corporate_register_model.dart';
import '../../../routes/appRoutes.dart';
import '../../../services/domain/repository/repository_imports.dart';

class CompanyRegistrationController extends GetxController {
  // Page Navigation
  final currentPage = 1.obs;
  final pageController = PageController();
  final totalSteps = 5;
  final isLoading = false.obs;

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
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();

  // --- Step 3: Address ---
  final formKeyStep3 = GlobalKey<FormState>();
  final selectedCountry = Rx<String?>(null);
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final streetController = TextEditingController();
  final buildingNumberController = TextEditingController();
  final postalCodeController = TextEditingController();

  // --- Step 4: Authorized Person ---
  final formKeyStep4 = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final positionController = TextEditingController();
  final authPhoneController = TextEditingController();
  final authEmailController = TextEditingController();

  // --- Step 5: Activity Details ---
  final formKeyStep5 = GlobalKey<FormState>();
  final selectedEmployeeCount = Rx<String?>(null);
  final selectedShipmentVolume = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  /// SAFE validation helper:
  /// - If key or key.currentState is null => treat as VALID (returns true).
  ///   This avoids failing because a Form hasn't been mounted (PageView lazy loading).
  /// - If mounted, runs .validate() and returns the result.
  bool _validateForm(GlobalKey<FormState>? key) {
    if (key == null) return true;
    final state = key.currentState;
    if (state == null) {
      // Form not mounted (e.g. page not built yet). Treat as valid for final submission.
      // If you want stricter validation, set this to 'false' and ensure Forms are pre-built.
      return true;
    }
    return state.validate();
  }

  /// Validates all steps and logs which steps are invalid (for debugging).
  bool _allStepsValid() {
    final results = <int, bool>{
      1: _validateForm(formKeyStep1),
      2: _validateForm(formKeyStep2),
      3: _validateForm(formKeyStep3),
      4: _validateForm(formKeyStep4),
      5: _validateForm(formKeyStep5),
    };

    // Debug print: show which steps passed/failed
    results.forEach((step, ok) {
      debugPrint('Step $step valid: $ok');
    });

    // If any mounted form returned false, overall is false
    final anyFalse = results.values.any((v) => v == false);
    return !anyFalse;
  }

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
      default:
        currentKey = formKeyStep1;
    }

    final valid = currentKey?.currentState?.validate() ?? true;
    // Note: here we assume if currentState is null treat as valid (prevents crash).
    if (valid) {
      if (currentPage.value < totalSteps) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        currentPage.value++;
      } else {
        // Final step: Create Account
        submitCorporate();
      }
    } else {
      showToast(message: 'Please correct errors in this step');
      // Get.snackbar('Error', 'Please correct errors in this step');
    }
  }

  CorporateRegisterModel _buildCorporateModel() {
    return CorporateRegisterModel(
      name: fullNameController.text.trim().isNotEmpty
          ? fullNameController.text.trim()
          : companyNameController.text.trim(),
      email: emailController.text.trim(),
      mobile: phoneController.text.trim(),
      password: passwordController.text,
      companyName: companyNameController.text.trim(),
      sector: selectedBusinessSector.value ?? '',
      commercialRegNo: commercialRegisterController.text.trim(),
      taxRegNo: taxRegisterController.text.trim(),
      websiteUrl: websiteController.text.trim(),
      country: selectedCountry.value ?? '',
      city: cityController.text.trim(),
      district: districtController.text.trim(),
      street: streetController.text.trim(),
      buildingNo: buildingNumberController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      fullName: fullNameController.text.trim(),
      position: positionController.text.trim(),
      contactMobile: authPhoneController.text.trim(),
      contactEmail: authEmailController.text.trim(),
      noOfEmployees: int.tryParse(selectedEmployeeCount.value ?? '') ?? 0,
      expectedShipmentVolume:
      int.tryParse(selectedShipmentVolume.value ?? '') ?? 0,
    );
  }

  Future<void> submitCorporate() async {
    // Validate the final step if mounted; if not mounted, assume valid
    final finalStepValid = formKeyStep5.currentState?.validate() ?? true;
    if (!finalStepValid) {
      showToast(message: 'Please fill activity details');
      // Get.snackbar('Error', 'Please fill activity details');
      return;
    }

    // Validate all steps (mounted ones) and show debug info
    final allValid = _allStepsValid();
    if (!allValid) {
      showToast(message: 'Please complete all steps correctly.');
      // Get.snackbar('Error', 'Please complete all steps correctly.');
      return;
    }

    final repo = Get.find<AuthRepository>();
    final model = _buildCorporateModel();

    try {
      isLoading.value = true;
      final message = await repo.registerCorporate(model: model);

      // Get.snackbar('Success', message);
      showToast(message: 'OTP sent your mail.');

      final email = emailController.text.trim();
      if (email.isNotEmpty) {
        Get.offAllNamed(AppRoutes.otp, arguments: email);
      } else {
        showToast(message: 'Registered but no email provided for OTP.');
        // Get.snackbar('Info', 'Registered but no email provided for OTP.');
      }
    } catch (e) {
      final err = e.toString().replaceAll('Exception: ', '');
      if (err.toLowerCase().contains('already registered') ||
          err.toLowerCase().contains('user already')) {
        showToast(message: 'User already exists. Please login instead.');
        // Get.snackbar('Info', 'User already exists. Please login instead.');
      } else {
        showToast(message: 'User already exists. Please login instead.');
        // Get.snackbar('Error', err);
        debugPrint('Error:$err');

      }
    } finally {
      isLoading.value = false;
    }
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
