import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyRegistrationController extends GetxController {
  final companyNameController = TextEditingController();
  final companyNameEnController = TextEditingController();
  final commercialRegisterController = TextEditingController();
  final taxRegisterController = TextEditingController();

  final selectedBusinessType = Rx<String?>(null);
  final selectedBusinessSector = Rx<String?>(null);

  final formKey = GlobalKey<FormState>();

  final isNextButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    companyNameController.addListener(_validateForm);
    companyNameEnController.addListener(_validateForm);
    commercialRegisterController.addListener(_validateForm);
    taxRegisterController.addListener(_validateForm);
    ever(selectedBusinessType, (_) => _validateForm());
    ever(selectedBusinessSector, (_) => _validateForm());
  }

  void _validateForm() {
    isNextButtonEnabled.value = companyNameController.text.isNotEmpty &&
        companyNameEnController.text.isNotEmpty &&
        commercialRegisterController.text.isNotEmpty &&
        taxRegisterController.text.isNotEmpty &&
        selectedBusinessType.value != null &&
        selectedBusinessSector.value != null;
  }

  void nextStep() {
    // Handle navigation to the next step
    if (formKey.currentState!.validate()) {
      // Logic to move to the next screen/step
      print('Form is valid. Moving to next step.');
    }
  }

  @override
  void onClose() {
    companyNameController.dispose();
    companyNameEnController.dispose();
    commercialRegisterController.dispose();
    taxRegisterController.dispose();
    super.onClose();
  }
}