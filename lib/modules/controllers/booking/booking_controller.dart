import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';

import '../../../routes/appRoutes.dart';

class BookingController extends GetxController {
  final ShipmentRepository repo = ShipmentRepository();
  // Booking
  var selectedTime = 0.obs;
  var selectedVehicleIndex = 0.obs;
  var weight = 0.0.obs;
  var selectedWeightUnit = 'Kg'.obs;
  var description = ''.obs;
  var isLoading = false.obs;
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

  Future<void> next() async {
    if (dnameController.text.isEmpty ||
        dmobileController.text.isEmpty ||
        dlankmarkController.text.isEmpty ||
        dpincodeController.text.isEmpty ||
        pNameController.text.isEmpty ||
        pMobileController.text.isEmpty ||
        pLandMarkController.text.isEmpty ||
        pPincodeController.text.isEmpty ||
        weight.value == 0 ||
        description.value == '') {
      Get.snackbar(
        "Error",
        "Please fill all required fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return;
    } else {
      try {
        isLoading.value = true;
        await fetchShipmentEstimate(
          originLat: pLat.value.toDouble(),
          originLng: pLng.value.toDouble(),
          destinationLat: dLat.value.toDouble(),
          destinationLng: dLng.value.toDouble(),
          weight: weight.value,
        );
        Get.toNamed(AppRoutes.confirm);

        isLoading.value = false;
      } catch (e) {}
    }
  }
  Future<void> fetchShipmentEstimate({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double weight,
  }) async {
    try {
      final res = await repo.estimateShipment(
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        weight: weight,
      );

      // check success
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        // parse and update controller observables safely
        distance.value = (data['distanceKm'] is num)
            ? (data['distanceKm'] as num).toDouble()
            : distance.value;
        durationText.value = (data['durationText'] ?? '').toString();
        estimatedCostINR.value = (data['estimatedCostINR'] is num)
            ? (data['estimatedCostINR'] as num).toDouble()
            : estimatedCostINR.value;
        estimatedCostUSD.value = (data['estimatedCostUSD'] is num)
            ? (data['estimatedCostUSD'] as num).toDouble()
            : estimatedCostUSD.value;
        currency.value = (data['currency'] ?? '').toString();

        // Use estimatedCostINR to show tripFare (optional)
        if (estimatedCostINR.value > 0) {
          tripFare.value = estimatedCostINR.value;
        }

        debugPrint('Shipment estimate updated in controller: $data');
      } else {
        debugPrint('Shipment create returned error or unexpected format: $res');
        // optionally show message
        Get.snackbar(
          'Estimate Failed',
          res['message']?.toString() ?? 'Unable to get estimate',
        );
      }
    } catch (e) {
      debugPrint('Error fetching shipment estimate: $e');
      Get.snackbar('Error', 'Failed to fetch estimate');
    }
  }
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  //  Pickup
  final pNameController = TextEditingController();
  final pMobileController = TextEditingController();
  final pLandMarkController = TextEditingController();
  final pPincodeController = TextEditingController();
  var pLocality = ''.obs;
  var pAddress = ''.obs;
  var pselectedAddressType = 'Home'.obs;
  var isPickUpFormValid = false.obs;
  var pLat = 0.0.obs;
  var pLng = 0.0.obs;

  void updatePickUpReactive() {
    // Combine address + landmark + pincode for display
    pAddress.value =
        "${pLocality},${dlankmarkController.text}, ${dpincodeController.text}";

    validatePickupForm();
  }

  void pselectAddressType(String type) {
    pselectedAddressType.value = type;
  }

  void validatePickupForm() {
    final bool allFieldsFilled =
        pNameController.text.isNotEmpty &&
        pMobileController.text.isNotEmpty &&
        pLandMarkController.text.isNotEmpty &&
        pPincodeController.text.isNotEmpty;
    isPickUpFormValid.value = allFieldsFilled;
  }

  void confirmPickupDetails() {
    if (pNameController.text.isEmpty ||
        pMobileController.text.isEmpty ||
        pLandMarkController.text.isEmpty ||
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
    updatePickUpReactive();
    print("Name: ${pNameController.text}");
    print("Mobile: ${pMobileController.text}");
    print("Lat: ${pLat}");
    print("Lang: ${pLng}");
    print("Address Type: ${pselectedAddressType.value}");

    Get.back();
  }

  // Drop-off controllers
  final dnameController = TextEditingController();
  final dmobileController = TextEditingController();
  final dlankmarkController = TextEditingController(); // landmark / house no
  final dpincodeController = TextEditingController();

  var dName = ''.obs;
  var dPhone = ''.obs;
  var dLocality = ''.obs;
  var dAddress = ''.obs;
  var dselectedAddressType = 'Home'.obs;
  var isDropOffFormValid = false.obs;
  var dLat = 0.0.obs;
  var dLng = 0.0.obs;

  // Update reactive fields whenever controllers change
  void updateDropOffReactive() {
    dName.value = dnameController.text;
    dPhone.value = dmobileController.text;
    // Combine address + landmark + pincode for display
    dAddress.value =
        "${dLocality},${dlankmarkController.text}, ${dpincodeController.text}";

    validateDropOffForm();
  }

  void validateDropOffForm() {
    isDropOffFormValid.value =
        dnameController.text.isNotEmpty &&
        dmobileController.text.isNotEmpty &&
        dlankmarkController.text.isNotEmpty &&
        dpincodeController.text.isNotEmpty;
  }

  void dselectAddressType(String type) {
    dselectedAddressType.value = type;
  }

  void confirmDropOffDetails() {
    if (!isDropOffFormValid.value) {
      Get.snackbar(
        "Error",
        "Please fill all required fields.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Update reactive values before going back
    updateDropOffReactive();

    print("Name: ${dName.value}");
    print("Mobile: ${dPhone.value}");
    print("Address: ${dAddress.value}");
    print("Lat: ${dLat}");
    print("Lang: ${dLng}");
    print("Address Type: ${dselectedAddressType.value}");

    Get.back();
  }

  // Booking Confirmation
  var isCouponApplied = true.obs;
  var appliedCouponCode = "2wi20".obs;

  var tripFare = 1500.0.obs;
  var couponDiscount = 100.0.obs;
  var gstCharges = 200.0.obs;
  var distance = 0.0.obs;

  var durationText = ''.obs;
  var estimatedCostINR = 0.0.obs;
  var estimatedCostUSD = 0.0.obs;
  var currency = ''.obs;
  var paypalApproveLink = ''.obs;
  var paypalOrderId = ''.obs;
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



  // void orderNow() {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text("Order Placed!"),
  //       content: Text(
  //         "Placing your order for ₹${amountPayable.toStringAsFixed(2)}...",
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () async {
  //             try {
  //               isLoading.value = true;
  //               final res = await repo.createShipment(
  //                 originLat: pLat.value.toDouble(),
  //                 originLng: pLng.value.toDouble(),
  //                 destinationLat: dLat.value.toDouble(),
  //                 destinationLng: dLng.value.toDouble(),
  //                 weight: weight.value,
  //               );
  //
  //               isLoading.value = false;
  //
  //               if (res['success'] == true) {
  //                 // some APIs return approveLink under different keys — adapt if needed
  //                 final approveLink = res['approveLink'] ?? res['data']?['approveLink'] ?? res['shipment']?['approveLink'] ?? res['approve_link'] ?? res['approveUrl'];
  //                 final orderId = res['orderId'] ?? res['shipment']?['paypalOrderId'] ?? res['order_id'];
  //
  //                 paypalApproveLink.value = approveLink?.toString() ?? '';
  //                 paypalOrderId.value = orderId?.toString() ?? '';
  //
  //                 debugPrint('Approve link: ${paypalApproveLink.value}');
  //
  //                 Get.back(); // close dialog
  //                 // Navigate to payment screen — pass nothing, controller holds link
  //                 Get.toNamed(AppRoutes.payment);
  //               } else {
  //                 Get.back();
  //                 Get.snackbar('Failed', res['message']?.toString() ?? 'Unable to create shipment');
  //               }
  //             } catch (e) {
  //               Get.back();
  //               isLoading.value = false;
  //               Get.snackbar('Error', 'Something went wrong');
  //             }
  //           },
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void orderNow() {
    Get.dialog(
      AlertDialog(
        title: const Text("Order Placed!"),
        content: Text(
          "Placing your order for ₹${amountPayable.toStringAsFixed(2)}...",
        ),
      ),
    );

    // Delay 2 seconds before moving to payment screen
    Future.delayed(const Duration(seconds: 2), () {
      // Assuming approveLink and orderId are already set somewhere
      paypalApproveLink.value = "your_approve_link_here"; // replace if dynamic
      paypalOrderId.value = "your_order_id_here";         // replace if dynamic

      Get.back(); // close dialog
      Get.toNamed(AppRoutes.payment);
    });
  }

  @override
  void onInit() {
    super.onInit();
    dnameController.addListener(validateDropOffForm);
    dmobileController.addListener(validateDropOffForm);
    dlankmarkController.addListener(validateDropOffForm);
    dpincodeController.addListener(validateDropOffForm);

    ever(dselectedAddressType, (_) => validateDropOffForm());

    pNameController.addListener(validatePickupForm);
    pMobileController.addListener(validatePickupForm);
    pLandMarkController.addListener(validatePickupForm);
    pPincodeController.addListener(validatePickupForm);

    ever(pselectedAddressType, (_) => validatePickupForm());
  }

  @override
  void onClose() {
    pNameController.dispose();
    pMobileController.dispose();
    pLandMarkController.dispose();
    pPincodeController.dispose();
    dnameController.dispose();
    dmobileController.dispose();
    dlankmarkController.dispose();
    dpincodeController.dispose();
    super.onClose();
  }
}
