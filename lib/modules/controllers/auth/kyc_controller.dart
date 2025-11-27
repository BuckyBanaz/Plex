// lib/modules/controllers/auth/driver_kyc_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/domain/repository/repository_imports.dart'; // adjust path if needed
import '../../../routes/appRoutes.dart';
import '../../../models/kyc_model.dart'; // if you created models earlier

class DriverKycController extends GetxController {
  final step = 0.obs;

  /// Store all 4 step images (0: license, 1: id card, 2: rc, 3: driver image)
  final images = List<Rxn<File>>.generate(4, (_) => Rxn<File>());

  /// Store all 3 step numbers (license, id card, rc)
  /// keep length 3 because there are only three number fields
  final numbers = List<String>.generate(3, (_) => "");

  var pickedImage = Rxn<File>();
  var inputNumber = ''.obs;

  final ImagePicker _picker = ImagePicker();

  // repository (must be registered in Get before using)
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  bool get canProceed {
    if (step.value == 3) {
      return pickedImage.value != null;
    }
    return pickedImage.value != null && inputNumber.value.trim().isNotEmpty;
  }

  Future pickImageFromGallery() async {
    // image decoding can be heavy: avoid doing large synchronous work on UI thread
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600, // reduce size to help avoid main-thread decoding issues
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

  void nextStep() {
    final int index = step.value;

    // Store values safely:
    // images has length 4 -> images[index] is valid for index 0..3
    if (index >= 0 && index < images.length) {
      images[index].value = pickedImage.value;
    } else {
      // defensive: unexpected index
      print("Warning: images index out of range: $index");
    }

    // Only write numbers when index is in numbers range
    if (index >= 0 && index < numbers.length) {
      numbers[index] = inputNumber.value.trim();
    }

    // Debug prints
    print("Saved Image for step $index → ${images[index].value?.path}");
    if (index >= 0 && index < numbers.length) {
      print("Saved Number for step $index → ${numbers[index]}");
    } else {
      print("No number for step $index (expected for profile image step)");
    }

    // Next step or submit
    if (step.value < images.length - 1) {
      // move to next step
      step.value++;
      pickedImage.value = null;
      inputNumber.value = '';
    } else {
      // final step -> submit
      _onSubmit();
    }
  }

  Future<void> _onSubmit() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Call repository submit method. This expects the 4 images and 3 numbers:
      final licenseImage = images[0].value;
      final idCardImage = images[1].value;
      final rcImage = images[2].value;
      final driverImage = images[3].value;

      if (licenseImage == null ||
          idCardImage == null ||
          rcImage == null ||
          driverImage == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar("Error", "Please provide all images before submitting KYC");
        return;
      }

      final licenseNumber = (numbers.length > 0) ? numbers[0] : '';
      final idCardNumber = (numbers.length > 1) ? numbers[1] : '';
      final rcNumber = (numbers.length > 2) ? numbers[2] : '';

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

      if (kycResponse.success && kycResponse.data != null) {
        Get.snackbar("Success", kycResponse.message ?? "KYC completed");

        final license = kycResponse.data?.extractedText?.license;
        final idCard = kycResponse.data?.extractedText?.idCard;
        final rc = kycResponse.data?.extractedText?.rc;
        final imagesResp = kycResponse.data?.images;

        // Raw values from backend
        final rawVehicleNumber = rc?.regNumber ?? '';
        final rawOwnerName = rc?.ownerName ?? license?.name ?? idCard?.name ?? '';
        String rawFuelType = rc?.fuelType ?? '';

        // -------------- Normalize owner name and fuel type --------------
        // cleanOwnerName also attempts to extract fuel type if merged
        final cleaned = _cleanOwnerNameAndExtractFuel(rawOwnerName, rawFuelType);
        final ownerName = cleaned.cleanedName;
        final fuelType = cleaned.fuelType;

        // -------------- Compute vehicle age --------------
        // prefer rc.regDate -> rc.regDate/issueDate/regValidity
        String vehicleAge = '';
        final regDateCandidates = <String?>[
          rc?.regDate,
          rc?.regValidity, // if backend uses regValidity for date range
          rc?.regDate, // duplicate intentionally harmless
        ];

        // also check license.issueDate / rc.issueDate if present in your model
        String? parsedRegDate;
        for (final s in regDateCandidates) {
          if (s != null && s.trim().isNotEmpty) {
            parsedRegDate = s.trim();
            break;
          }
        }

        // If rc.issueDate exists (like "17/11/2023") try it too
        if (parsedRegDate == null && (rc is RcText) && (rc.regDate == null)) {
          // attempt fallback keys that might exist in JSON like 'issueDate' or 'regDate'
          // we already attempted rc.regDate above; here we try license.issueDate or other fields
          parsedRegDate = license?.issueDate ?? rc?.regDate;
        }

        if (parsedRegDate != null) {
          final age = _computeAgeFromString(parsedRegDate);
          if (age != null) vehicleAge = age;
        } else {
          // No reg date found: try license.issueDate or idCard.dob as last resort
          if (license?.issueDate != null) {
            final a = _computeAgeFromString(license!.issueDate!);
            if (a != null) vehicleAge = a;
          }
        }

        // -------------- Prepare other fields --------------
        final vehicleNumber = rawVehicleNumber;
        final registeringAuth = imagesResp?.rcUrl ?? '';
        final vehicleType = ''; // backend doesn't provide - leave blank or infer later
        final vehicleStatus = 'Inactive';
        final vehicleImageUrl = imagesResp?.rcUrl ?? imagesResp?.driverUrl ?? null;

        // pass cleaned/normalized fields to vehicle entry screen
        Get.toNamed(
          AppRoutes.vehicleEntry,
          arguments: {
            'vehicleNumber': vehicleNumber,
            'ownerName': ownerName,
            'registeringAuth': registeringAuth,
            'vehicleType': vehicleType,
            'fuelType': fuelType,
            'vehicleAge': vehicleAge,
            'vehicleStatus': vehicleStatus,
            'vehicleImageUrl': vehicleImageUrl,
            // optionally pass license / id info if needed on next screen
            'licenseInfo': {
              'licenseNumber': license?.licenseNumber,
              'dob': license?.dob,
              'issueDate': license?.issueDate,
              'validTill': license?.validTill,
              'name': license?.name,
              'fatherName': license?.fatherName,
            },
            'idCardInfo': {
              'aadhaarNumber': idCard?.aadhaarNumber,
              'name': idCard?.name,
              'mobile': idCard?.mobile,
              'dob': idCard?.dob,
              'gender': idCard?.gender,
            },
            'rcInfo': {
              'regNumber': rc?.regNumber,
              'ownerName': ownerName,
              'engineNumber': rc?.engineNumber,
              'fuelType': fuelType,
              'rawOwnerName': rawOwnerName, // keep raw for debugging if needed
            },
          },
        );
      } else {
        Get.snackbar("KYC Failed", kycResponse.message ?? "Unable to complete KYC");
      }
    } catch (e, st) {
      if (Get.isDialogOpen ?? false) Get.back();
      print("KYC submit failed: $e\n$st");
      Get.snackbar("Error", "Failed to submit KYC. Try again.");
    }
  }

}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
/// Returns a tuple-like object with cleanedName and fuelType.
class _NameFuelResult {
  final String cleanedName;
  final String fuelType;
  _NameFuelResult(this.cleanedName, this.fuelType);
}

/// Cleans owner name and tries to extract fuel type if merged into the string.
/// Removes common OCR garbage like "Fuel Used", "Son/Daughter/Wife of", "Address", "Owner", trailing numbers etc.
_NameFuelResult _cleanOwnerNameAndExtractFuel(String rawName, String fallbackFuel) {
  if (rawName.trim().isEmpty) {
    return _NameFuelResult('', fallbackFuel ?? '');
  }
  String s = rawName.trim();

  // Normalize spaces
  s = s.replaceAll(RegExp(r'\s+'), ' ');

  // Common fuel words to search for
  final fuelWords = ['PETROL', 'DIESEL', 'CNG', 'LPG', 'Electric', 'ELECTRIC', 'PETROl'];

  String foundFuel = fallbackFuel.trim() ?? '';

  // If fuel word exists in string, extract it
  for (final f in fuelWords) {
    final match = RegExp(r'\b' + RegExp.escape(f) + r'\b', caseSensitive: false).firstMatch(s);
    if (match != null) {
      foundFuel = f.toUpperCase();
      // remove the matched fuel and nearby noisy tokens
      s = s.replaceRange(match.start, match.end, '');
      break;
    }
  }

  // Remove patterns like "Fuel Used", "Son/Daughter/Wife of", "Owner", "Address", "Fuel Used Son"
  s = s.replaceAll(RegExp(r'Fuel Used.*', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'Son\/Daughter\/Wife of', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'\b(Son|Daughter|Wife)\b', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'\b(Owner|Owner Name|Address|Fuel Used)\b', caseSensitive: false), '');

  // Remove stray punctuation and numbers that are unlikely to be part of name
  s = s.replaceAll(RegExp(r'[^A-Za-z\s]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // If result is empty, fallback to first token-like chunk from rawName before common separators
  if (s.isEmpty) {
    final alt = rawName.split(RegExp(r'[,\n/]')).firstWhere((p) => p.trim().isNotEmpty, orElse: () => '');
    s = alt.replaceAll(RegExp(r'[^A-Za-z\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Ensure proper case (all caps in sample -> keep as-is or title case if you prefer)
  // We'll keep uppercase to match other fields
  s = s.toUpperCase();

  return _NameFuelResult(s, foundFuel);
}

/// Parse date strings like "17/11/2023", "03-08-2023", "03/08/23", "03/08/2023 00:00:00"
/// Returns computed age in 'X years Y months' or null if cannot compute.
String? _computeAgeFromString(String dateStr) {
  final s = dateStr.trim();

  // Try to find pattern dd/mm/yyyy or dd-mm-yyyy
  final match = RegExp(r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})').firstMatch(s);
  if (match != null) {
    try {
      final dd = int.parse(match.group(1)!);
      final mm = int.parse(match.group(2)!);
      var yy = int.parse(match.group(3)!);
      if (yy < 100) yy += 2000;
      final regDate = DateTime(yy, mm, dd);
      final now = DateTime.now();

      int years = now.year - regDate.year;
      int months = now.month - regDate.month;
      if (now.day < regDate.day) months--;
      if (months < 0) {
        years--;
        months += 12;
      }
      final parts = <String>[];
      if (years > 0) parts.add('$years year${years > 1 ? "s" : ""}');
      if (months > 0) parts.add('$months month${months > 1 ? "s" : ""}');
      if (parts.isEmpty) return '0 months';
      return parts.join(' ');
    } catch (_) {
      return null;
    }
  }

  // attempt ISO parse
  try {
    final dt = DateTime.parse(s);
    final now = DateTime.now();
    int years = now.year - dt.year;
    int months = now.month - dt.month;
    if (now.day < dt.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    final parts = <String>[];
    if (years > 0) parts.add('$years year${years > 1 ? "s" : ""}');
    if (months > 0) parts.add('$months month${months > 1 ? "s" : ""}');
    if (parts.isEmpty) return '0 months';
    return parts.join(' ');
  } catch (_) {}

  return null;
}
