import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

import '../../../routes/appRoutes.dart';

class DriverKycController extends GetxController {
  final step = 0.obs;

  /// Store all 4 step images
  final images = List<Rxn<File>>.generate(4, (_) => Rxn<File>());

  /// Store all 3 step numbers
  final numbers = List<String>.generate(3, (_) => "");

  var pickedImage = Rxn<File>();
  var inputNumber = ''.obs;

  final ImagePicker _picker = ImagePicker();

  bool get canProceed {
    if (step.value == 3) {
      return pickedImage.value != null;
    }
    return pickedImage.value != null && inputNumber.value.trim().isNotEmpty;
  }

  Future pickImageFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) pickedImage.value = File(file.path);
  }

  Future captureImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null) pickedImage.value = File(file.path);
  }

  void nextStep() {
    int index = step.value;

    // Store values
    images[index].value = pickedImage.value;
    if (index != 3) numbers[index] = inputNumber.value;

    // Get.toNamed(AppRoutes.approvel);
    // Debug print
    print("Saved Image for step $index → ${images[index].value?.path}");
    print("Saved Number for step $index → ${numbers[index]}");

    // Next step
    if (step.value < 3) {
      step.value++;
      pickedImage.value = null;
      inputNumber.value = '';
    } else {
      _onSubmit();
    }
  }

  void _onSubmit() {
    print("----- FINAL STORED DATA -----");
    print("License Image → ${images[0].value?.path}");
    print("License Number → ${numbers[0]}");

    print("ID Card Image → ${images[1].value?.path}");
    print("ID Card Number → ${numbers[1]}");

    print("RC Image → ${images[2].value?.path}");
    print("RC Number → ${numbers[2]}");

    print("Profile Photo → ${images[3].value?.path}");

    Get.snackbar("Success", "KYC Submitted!");
  }
}
