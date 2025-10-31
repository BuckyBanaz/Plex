import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import '../../../routes/appRoutes.dart';
import '../payment/stripe_payment_controller.dart';



class BookingController extends GetxController {
  final ShipmentRepository repo = ShipmentRepository();
  GoogleMapController? mapController; // <-- FIX 1: Map controller add karein

  
  // Booking fields
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
        permission = androidInfo.version.sdkInt >= 33
            ? Permission.photos
            : Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    var status = await permission.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        "permission_required".tr,
        "please_enable_permissions".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      await openAppSettings();
      return false;
    }

    status = await permission.request();

    if (status.isGranted) return true;

    Get.snackbar(
      status.isDenied ? "permission_denied".tr : "permission_required".tr,
      "permission_required_to_select".tr,
      snackPosition: SnackPosition.BOTTOM,
    );

    if (status.isPermanentlyDenied) await openAppSettings();

    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    if (!await _requestPermission(source)) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) selectedImages.add(image);
  }

  Future<void> next() async {
    // Validate Pickup
    if (pNameController.text.trim().isEmpty ||
        pMobileController.text.trim().isEmpty ||
        pLandMarkController.text.trim().isEmpty ||
        pPincodeController.text.trim().isEmpty) {
      Get.snackbar(
        "error".tr,
        "fill_pickup_fields".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    // Validate Drop-off
    if (dnameController.text.trim().isEmpty ||
        dmobileController.text.trim().isEmpty ||
        dlankmarkController.text.trim().isEmpty ||
        dpincodeController.text.trim().isEmpty) {
      Get.snackbar(
        "error".tr,
        "fill_dropoff_fields".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Weight and description
    if (weight.value == 0) {
      Get.snackbar(
        "error".tr,
        "weight_required".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (description.value.trim().isEmpty) {
      Get.snackbar(
        "error".tr,
        "description_required".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // If all valid
    try {
      isLoading.value = true;
      await fetchShipmentEstimate(
        originLat: pLat.value,
        originLng: pLng.value,
        destinationLat: dLat.value,
        destinationLng: dLng.value,
        weight: weight.value,
      );
      Get.toNamed(AppRoutes.confirm);
    } finally {
      isLoading.value = false;
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

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        distance.value =
            (data['distanceKm'] as num?)?.toDouble() ?? distance.value;
        durationText.value = (data['durationText'] ?? '').toString();
        estimatedCostINR.value =
            (data['estimatedCostINR'] as num?)?.toDouble() ??
                estimatedCostINR.value;
        estimatedCostUSD.value =
            (data['estimatedCostUSD'] as num?)?.toDouble() ??
                estimatedCostUSD.value;
        currency.value = (data['currency'] ?? '').toString();
        if (estimatedCostINR.value > 0) tripFare.value = estimatedCostINR.value;
      } else {
        Get.snackbar(
          'estimate_failed'.tr,
          res['message']?.toString() ?? 'unable_to_get_estimate'.tr,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_fetch_estimate'.tr);
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length)
      selectedImages.removeAt(index);
  }

  // Pickup controllers
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
    pAddress.value =
    "${pLocality},${pLandMarkController.text}, ${pPincodeController.text}";
    validatePickupForm();
  }

  void pselectAddressType(String type) => pselectedAddressType.value = type;

  void validatePickupForm() {
    isPickUpFormValid.value = pNameController.text.isNotEmpty &&
        pMobileController.text.isNotEmpty &&
        pLandMarkController.text.isNotEmpty &&
        pPincodeController.text.isNotEmpty &&
        pLat.value != 0.0 &&
        pLng.value != 0.0;
  }

  void confirmPickupDetails() {
    if (!isPickUpFormValid.value) {
      Get.snackbar(
        "error".tr,
        "fill_all_fields".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    updatePickUpReactive();
    fetchRoute(); // <-- FIX 2: Yahan fetchRoute() call karein
    Get.back();
  }

  // Drop-off controllers
  final dnameController = TextEditingController();
  final dmobileController = TextEditingController();
  final dlankmarkController = TextEditingController();
  final dpincodeController = TextEditingController();
  var dName = ''.obs;
  var dPhone = ''.obs;
  var dLocality = ''.obs;
  var dAddress = ''.obs;
  var dselectedAddressType = 'Home'.obs;
  var isDropOffFormValid = false.obs;
  var dLat = 0.0.obs;
  var dLng = 0.0.obs;

  void updateDropOffReactive() {
    dName.value = dnameController.text;
    dPhone.value = dmobileController.text;
    dAddress.value =
    "${dLocality},${dlankmarkController.text}, ${dpincodeController.text}";
    validateDropOffForm();
  }

  void dselectAddressType(String type) => dselectedAddressType.value = type;

  void validateDropOffForm() {
    isDropOffFormValid.value = dnameController.text.isNotEmpty &&
        dmobileController.text.isNotEmpty &&
        dlankmarkController.text.isNotEmpty &&
        dpincodeController.text.isNotEmpty &&
        dLat.value != 0.0 &&
        dLng.value != 0.0;
  }

  void confirmDropOffDetails() {
    if (!isDropOffFormValid.value) {
      Get.snackbar(
        "error".tr,
        "fill_all_fields".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    updateDropOffReactive();
    fetchRoute(); // <-- FIX 2: Yahan bhi fetchRoute() call karein
    Get.back();
  }

  // Location Details

  var routePoints = <LatLng>[].obs;
  final MapRepository mapRepo = MapRepository();

  Future<void> fetchRoute() async {
    if (pLat.value == 0.0 || dLat.value == 0.0) return;
    final points = await mapRepo.getRoute(
      originLat: pLat.value,
      originLng: pLng.value,
      destLat: dLat.value,
      destLng: dLng.value,
    );

    routePoints.value = points.map((e) => LatLng(e['lat']!, e['lng']!)).toList();

    // <-- FIX 3: Camera zoom logic add karein -->
    if (mapController != null && routePoints.isNotEmpty) {
      LatLngBounds bounds;

      if (routePoints.length == 1) {
        // Sirf ek point hai toh uspe center karo
        bounds = LatLngBounds(
            southwest: routePoints.first, northeast: routePoints.first);
      } else {
        // Multiple points hain toh bounds calculate karo
        bounds = LatLngBounds(
          southwest: LatLng(
            routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
            routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
            routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
          ),
        );
      }

      // Camera ko new bounds par animate karo
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0), // 50.0 padding hai
      );
    }
    // <-- FIX 3 END -->
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
  var shipmentClientSecret = ''.obs;
  double get totalFare =>
      tripFare.value -
          (isCouponApplied.value ? couponDiscount.value : 0) +
          gstCharges.value;
  double get amountPayable => totalFare;

  void removeCoupon() {
    isCouponApplied.value = false;
    Get.snackbar(
      "coupon_removed".tr,
      "coupon_removed_message".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void orderNow() {
    Get.dialog(
      AlertDialog(
        title: const Text("Order Placed!"),
        content: Text(
          "Placing your order for ₹${amountPayable.toStringAsFixed(2)}...",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                isLoading.value = true;
                final res = await repo.createShipment(
                  originLat: pLat.value.toDouble(),
                  originLng: pLng.value.toDouble(),
                  destinationLat: dLat.value.toDouble(),
                  destinationLng: dLng.value.toDouble(),
                  weight: weight.value,
                );

                isLoading.value = false;

                // clientSecret save
                shipmentClientSecret.value = res['clientSecret'] ?? '';

                Get.toNamed(AppRoutes.payment);
              } catch (e) {
                Get.back();
                isLoading.value = false;
                Get.snackbar('Error', 'Something went wrong');
              }
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
    mapController?.dispose(); // <-- FIX 4: Controller ko dispose karein
    super.onClose();
  }
}