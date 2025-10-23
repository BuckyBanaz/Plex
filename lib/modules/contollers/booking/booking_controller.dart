import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../routes/appRoutes.dart'; // Naya import

class BookingController extends GetxController {
  // Booking
  var selectedTime = 0.obs;
  var selectedVehicleIndex = 0.obs;
  var weight = 0.0.obs;
  var selectedWeightUnit = 'Kg'.obs;
  var description = ''.obs;
  var selectedImages = <XFile>[].obs;
  void selectTime(int index) => selectedTime.value = index;
  void selectVehicle(int index) => selectedVehicleIndex.value = index;
  void setWeight(double value) => weight.value = value;
  void setDescription(String value) => description.value = value;
  void setWeightUnit(String unit) => selectedWeightUnit.value = unit;

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (GetPlatform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }
      } else {
        permission = Permission.photos;
      }
    }

    var status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        "Permission Required",
        "Please enable permissions from your app settings to continue.",
        snackPosition: SnackPosition.BOTTOM,
      );
      await openAppSettings();
      return false;
    }

    status = await permission.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      Get.snackbar(
        "Permission Denied",
        "Permission is required to select photos. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        "Permission Required",
        "Please enable permissions from your app settings to continue.",
        snackPosition: SnackPosition.BOTTOM,
      );
      await openAppSettings();
    }

    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    bool hasPermission = await _requestPermission(source);
    if (!hasPermission) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      selectedImages.add(image);
    }
  }

  void next(){
    if (dnameController.text.isEmpty ||
        dmobileController.text.isEmpty ||
        daddressController.text.isEmpty ||
        dpincodeController.text.isEmpty||pNameController.text.isEmpty ||
        pMobileController.text.isEmpty ||
        pAddressController.text.isEmpty ||
        pPincodeController.text.isEmpty || weight.value == 0 ||description.value == '') {




      Get.snackbar(
        "Error",
        "Please fill all required fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );


      return;
    }
    Get.toNamed(AppRoutes.confirm);
  }
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  //  Pickup
  final pNameController = TextEditingController();
  final pMobileController = TextEditingController();
  final pAddressController = TextEditingController();
  final pPincodeController = TextEditingController();
  var pselectedAddressType = 'Home'.obs;
  var isPickUpFormValid = false.obs;

  void pselectAddressType(String type) {
    pselectedAddressType.value = type;
  }

  void validatePickupForm() {
    final bool allFieldsFilled =
        pNameController.text.isNotEmpty &&
        pMobileController.text.isNotEmpty &&
        pAddressController.text.isNotEmpty &&
        pPincodeController.text.isNotEmpty;
    isPickUpFormValid.value = allFieldsFilled;
  }

  void confirmPickupDetails() {

    if (pNameController.text.isEmpty ||
        pMobileController.text.isEmpty ||
        pAddressController.text.isEmpty ||
        pPincodeController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

     print("Name: ${pNameController.text}");
    print("Mobile: ${pMobileController.text}");
    print("Address Type: ${pselectedAddressType.value}");


    Get.back();
  }

  // Drop off
  final dnameController = TextEditingController();
  final dmobileController = TextEditingController();
  final daddressController = TextEditingController();
  final dpincodeController = TextEditingController();
  var dselectedAddressType = 'Home'.obs;
  var isDropOffFormValid = false.obs;

  void validateDropOffForm() {
    final bool allFieldsFilled =
        dnameController.text.isNotEmpty &&
        dmobileController.text.isNotEmpty &&
        daddressController.text.isNotEmpty &&
        dpincodeController.text.isNotEmpty;
    isDropOffFormValid.value = allFieldsFilled;
  }

  void dselectAddressType(String type) {
    dselectedAddressType.value = type;
  }

  void confirmDropOffDetails() {
    if (dnameController.text.isEmpty ||
        dmobileController.text.isEmpty ||
        daddressController.text.isEmpty ||
        dpincodeController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print("Name: ${dnameController.text}");
    print("Mobile: ${dmobileController.text}");
    print("Address Type: ${dselectedAddressType.value}");



    Get.back();
  }

  // Booking Confirmation
  var isCouponApplied = true.obs;
  var appliedCouponCode = "2wi20".obs;

  var tripFare = 1500.0.obs;
  var couponDiscount = 100.0.obs;
  var gstCharges = 200.0.obs;

  double get totalFare =>
      tripFare.value -
      (isCouponApplied.value ? couponDiscount.value : 0) +
      gstCharges.value;

  double get amountPayable => totalFare;

  void removeCoupon() {
    isCouponApplied.value = false;
    Get.snackbar(
      "Coupon Removed",
      "Coupon has been removed.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void orderNow() {

    Get.dialog(
      AlertDialog(
        title: const Text("Order Placed!"),
        content: Text(
          "Your order for ₹${amountPayable.toStringAsFixed(2)} has been confirmed.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // Get.offAll(() => HomeScreen()); // User ko Home screen par bhej dein
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();

    dnameController.addListener(validateDropOffForm);
    dmobileController.addListener(validateDropOffForm);
    daddressController.addListener(validateDropOffForm);
    dpincodeController.addListener(validateDropOffForm);

    ever(dselectedAddressType, (_) => validateDropOffForm());

    pNameController.addListener(validatePickupForm);
    pMobileController.addListener(validatePickupForm);
    pAddressController.addListener(validatePickupForm);
    pPincodeController.addListener(validatePickupForm);

    ever(pselectedAddressType, (_) => validatePickupForm());
  }

  @override
  void onClose() {
    pNameController.dispose();
    pMobileController.dispose();
    pAddressController.dispose();
    pPincodeController.dispose();
    dnameController.dispose();
    dmobileController.dispose();
    daddressController.dispose();
    dpincodeController.dispose();
    super.onClose();
  }
}
