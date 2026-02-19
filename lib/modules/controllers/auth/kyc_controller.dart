// lib/modules/controllers/auth/driver_kyc_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';

import '../../../services/domain/repository/repository_imports.dart';
import '../../../routes/appRoutes.dart';

class DriverKycController extends GetxController {
  final step = 0.obs;

  /// Store all 4 step images (0: license, 1: id card, 2: rc, 3: driver photo)
  final images = List<Rxn<File>>.generate(4, (_) => Rxn<File>());

  /// Store all 3 step numbers (license, id card, rc)
  final numbers = List<String>.generate(3, (_) => "");

  var pickedImage = Rxn<File>();
  var inputNumber = ''.obs;

  final ImagePicker _picker = ImagePicker();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  // Step labels for UI
  final stepLabels = [
    'Driving License',
    'ID Card (Aadhaar)',
    'Vehicle RC',
    'Profile Photo',
  ];

  // Input hints for each step
  final inputHints = [
    'Enter License Number',
    'Enter Aadhaar/ID Card Number',
    'Enter Vehicle Registration Number',
    '', // No input for photo step
  ];

  bool get canProceed {
    if (step.value == 3) {
      return pickedImage.value != null;
    }
    return pickedImage.value != null && inputNumber.value.trim().isNotEmpty;
  }

  /// Check if current step has a saved image
  bool get hasCurrentStepImage {
    final idx = step.value;
    if (idx >= 0 && idx < images.length) {
      return images[idx].value != null || pickedImage.value != null;
    }
    return false;
  }

  /// Get current step's saved number
  String get currentStepNumber {
    final idx = step.value;
    if (idx >= 0 && idx < numbers.length) {
      return numbers[idx];
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    // Load saved values when step changes
    ever(step, (_) => _loadStepData());
  }

  void _loadStepData() {
    final idx = step.value;
    // Load previously saved image for this step
    if (idx >= 0 && idx < images.length) {
      pickedImage.value = images[idx].value;
    }
    // Load previously saved number for this step
    if (idx >= 0 && idx < numbers.length) {
      inputNumber.value = numbers[idx];
    } else {
      inputNumber.value = '';
    }
  }

  Future pickImageFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file != null) pickedImage.value = File(file.path);
  }

  Future captureImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file != null) pickedImage.value = File(file.path);
  }

  /// Go to previous step
  void previousStep() {
    if (step.value > 0) {
      // Save current step data first
      _saveCurrentStepData();
      step.value--;
    }
  }

  /// Go to next step or submit if on last step
  void nextStep() {
    _saveCurrentStepData();

    if (step.value < images.length - 1) {
      step.value++;
      // Clear for next step (will be loaded from saved data if exists)
      pickedImage.value = null;
      inputNumber.value = '';
      _loadStepData();
    } else {
      // Final step - submit
      _onSubmit();
    }
  }

  void _saveCurrentStepData() {
    final idx = step.value;

    // Save image
    if (idx >= 0 && idx < images.length) {
      images[idx].value = pickedImage.value;
    }

    // Save number (only for steps 0-2)
    if (idx >= 0 && idx < numbers.length) {
      numbers[idx] = inputNumber.value.trim();
    }

    debugPrint("Saved step $idx: image=${images[idx].value?.path}, number=${idx < numbers.length ? numbers[idx] : 'N/A'}");
  }

  Future<void> _onSubmit() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        barrierDismissible: false,
      );

      final licenseImage = images[0].value;
      final idCardImage = images[1].value;
      final rcImage = images[2].value;
      final driverImage = images[3].value;

      if (licenseImage == null ||
          idCardImage == null ||
          rcImage == null ||
          driverImage == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        CustomSnackbar.error(
          "Please provide all required images",
          title: "Missing Documents",
        );
        return;
      }

      final licenseNumber = numbers.isNotEmpty ? numbers[0] : '';
      final idCardNumber = numbers.length > 1 ? numbers[1] : '';
      final rcNumber = numbers.length > 2 ? numbers[2] : '';

      final kycResponse = await _authRepo.submitDriverKyc(
        licenseNumber: licenseNumber,
        idCardNumber: idCardNumber,
        rcNumber: rcNumber,
        licenseImage: licenseImage,
        idCardImage: idCardImage,
        rcImage: rcImage,
        driverImage: driverImage,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (kycResponse.success) {
        CustomSnackbar.success(
          kycResponse.message ?? "KYC documents submitted successfully",
          title: "Success",
        );

        // Navigate to vehicle details screen
        // User will manually enter vehicle details
        Get.toNamed(
          AppRoutes.vehicleEntry,
          arguments: {
            'vehicleNumber': rcNumber,
            'ownerName': '',
            'registeringAuth': '',
            'vehicleType': '',
            'fuelType': '',
            'vehicleAge': '',
            'vehicleStatus': 'Pending',
            'vehicleImageUrl': null,
            'kycId': kycResponse.data?.kycId,
          },
        );
      } else {
        CustomSnackbar.error(
          kycResponse.message ?? "Unable to submit KYC. Please try again.",
          title: "KYC Failed",
        );
      }
    } catch (e, st) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("KYC submit failed: $e\n$st");
      CustomSnackbar.error(
        "Failed to submit KYC. Please check your connection and try again.",
        title: "Error",
      );
    }
  }

  /// Reset all data
  void reset() {
    step.value = 0;
    for (var img in images) {
      img.value = null;
    }
    for (int i = 0; i < numbers.length; i++) {
      numbers[i] = '';
    }
    pickedImage.value = null;
    inputNumber.value = '';
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
