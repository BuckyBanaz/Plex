import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:plex_user/common/Toast/toast.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import '../../../models/user_models.dart';
import '../../../routes/appRoutes.dart';
import '../../../services/domain/service/app/app_service_imports.dart';
import '../location/location_permission_controller.dart';
import '../payment/stripe_payment_controller.dart';

class BookingController extends GetxController {
  final ShipmentRepository repo = ShipmentRepository();
  GoogleMapController? mapController;
  final DatabaseService db = Get.find<DatabaseService>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Location controller (must be already put into Get before this controller is used)
  final LocationController locationController = Get.put(LocationController());


  // Booking fields
  var selectedTime = 0.obs;
  var selectedVehicleIndex = 0.obs;
  var weight = 0.0.obs;
  var selectedWeightUnit = 'Kg'.obs;
  var description = ''.obs;
  var isLoading = false.obs;
  var selectedImages = <XFile>[].obs;
  // add near other reactive fields
  var scheduledDateTime = Rxn<DateTime>(); // null when not selected

  // setter
  void setScheduledDateTime(DateTime dt) => scheduledDateTime.value = dt;

  // modify selectTime to optionally clear scheduledDateTime when immediate chosen
  void selectTime(int index) {
    selectedTime.value = index;
    if (index == 0) {
      // if immediate selected, clear any previously picked schedule
      scheduledDateTime.value = null;
    }
  }
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
      showToast(message: "fill_pickup_fields".tr);
      return;
    }
    // Validate Drop-off
    if (dnameController.text.trim().isEmpty ||
        dmobileController.text.trim().isEmpty ||
        dlankmarkController.text.trim().isEmpty ||
        dpincodeController.text.trim().isEmpty) {
      
      showToast(message: "fill_dropoff_fields".tr);
      return;
    }
    if (selectedTime.value == 1 && scheduledDateTime.value == null) {
     
     showToast(message:  "please_select_schedule_datetime".tr,);
    
      return;
    }
    // Weight and description
    if (weight.value == 0) {
      
      showToast(message: "weight_required".tr);
      return;
    }
    if (description.value.trim().isEmpty) {
      showToast(message: "description_required".tr,);
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
        "${pLocality.value},${pLandMarkController.text}, ${pPincodeController.text}";
    validatePickupForm();
  }

  void pselectAddressType(String type) => pselectedAddressType.value = type;

  void validatePickupForm() {
    isPickUpFormValid.value =
        pNameController.text.isNotEmpty &&
        pMobileController.text.isNotEmpty &&
        pLandMarkController.text.isNotEmpty &&
        pPincodeController.text.isNotEmpty &&
        pLat.value != 0.0 &&
        pLng.value != 0.0;
  }

  void confirmPickupDetails() {
    if (!isPickUpFormValid.value) {
      showToast(message: "fill_all_fields".tr);
      return;
    }
    updatePickUpReactive();
    fetchRoute();
    // Get.back();
    Get.back(closeOverlays: false);
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;

      final UserData = db.user;
      if (UserData != null) {
        currentUser.value = UserData;
        pNameController.text = UserData!.name;
        pMobileController.text = UserData!.mobile;
        print("User:${currentUser.value?.name}");
      } else {
        print("No User data found in local DB.");
      }
    } catch (e) {
      print("Failed to load User data: $e");
    } finally {
      isLoading.value = false;
    }
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
        "${dLocality.value},${dlankmarkController.text}, ${dpincodeController.text}";
    validateDropOffForm();
  }

  void dselectAddressType(String type) => dselectedAddressType.value = type;

  void validateDropOffForm() {
    isDropOffFormValid.value =
        dnameController.text.isNotEmpty &&
        dmobileController.text.isNotEmpty &&
        dlankmarkController.text.isNotEmpty &&
        dpincodeController.text.isNotEmpty &&
        dLat.value != 0.0 &&
        dLng.value != 0.0;
  }

  void confirmDropOffDetails() {
    if (!isDropOffFormValid.value) {

      showToast(message: "fill_all_fields".tr,);
      return;
    }
    updateDropOffReactive();
    fetchRoute();
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

    routePoints.value = points
        .map((e) => LatLng(e['lat']!, e['lng']!))
        .toList();

    // Camera zoom logic
    if (mapController != null && routePoints.isNotEmpty) {
      LatLngBounds bounds;

      if (routePoints.length == 1) {
        bounds = LatLngBounds(
          southwest: routePoints.first,
          northeast: routePoints.first,
        );
      } else {
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

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    }
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
  var stripePaymentIntentId = ''.obs;
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
// inside BookingController class

  /// Create shipment on server with chosen payment method.
  /// Returns the API response Map on success, or null on failure.
  Future<Map<String, dynamic>?> createShipmentAndPreparePayment({
    required String paymentMethod,
  }) async {
    try {
      isLoading.value = true;

      final res = await repo.createShipment(
        vehicleType: selectedVehicleIndex.value == 0 ? "Bike" : selectedVehicleIndex.value == 1 ? "Car" : "Van",
        originLat: pLat.value,
        originLng: pLng.value,
        paymentMethod: paymentMethod.toLowerCase(), // <- important: pass selected payment method
        destinationLat: dLat.value,
        destinationLng: dLng.value,
        weight: weight.value,
        weightUnit: selectedWeightUnit.value,
        notes: description.value,
        pickup: {
          "name": pNameController.text,
          "phone": pMobileController.text,
          "address": pAddress.value,
          "latitude": pLat.value,
          "longitude": pLng.value,
        },
        dropoff: {
          "name": dnameController.text,
          "phone": dmobileController.text,
          "address": dAddress.value,
          "latitude": dLat.value,
          "longitude": dLng.value,
        },
        collectType: selectedTime.value == 0 ? "immediate" : "scheduled",
        scheduledAt: selectedTime.value == 1 ? scheduledDateTime.value : null,
        imageUrls: selectedImages.isNotEmpty ? selectedImages.map((x) => x.path).toList() : null,
      );

      isLoading.value = false;

      if (res.containsKey('error')) {
        Get.snackbar("Error", res['error'].toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return null;
      }

      // Extract payment keys safely (top-level or nested in shipment)
      final shipment = (res['shipment'] is Map) ? Map<String, dynamic>.from(res['shipment']) : null;

      final clientSecretFromShipment = shipment != null ? (shipment['clientSecret']?.toString() ?? '') : '';
      final clientSecretTopLevel = res['clientSecret']?.toString() ?? '';
      shipmentClientSecret.value = clientSecretTopLevel.isNotEmpty ? clientSecretTopLevel : clientSecretFromShipment;

      final intentFromShipment = shipment != null ? (shipment['stripePaymentIntentId']?.toString() ?? '') : '';
      final intentTopLevel = res['stripePaymentIntentId']?.toString() ?? '';
      stripePaymentIntentId.value = intentTopLevel.isNotEmpty ? intentTopLevel : intentFromShipment;

      debugPrint("Extracted clientSecret: ${shipmentClientSecret.value}");
      debugPrint("Extracted stripePaymentIntentId: ${stripePaymentIntentId.value}");

      return Map<String, dynamic>.from(res);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'failed_create_shipment'.tr);
      debugPrint("createShipmentAndPreparePayment error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

   void orderNow() {
    // Simple confirmation dialog (optional) — you can remove dialog entirely and directly navigate
    Get.dialog(
      AlertDialog(
        title: const Text("Confirm Order"),
        content: Text(
          "Proceed to payment for ₹${amountPayable.toStringAsFixed(2)}?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              // Navigate to payment screen — UserPaymentController.proceedPayment() will create shipment & handle payment
              Get.toNamed(AppRoutes.payment);
            },
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
  // void orderNow() {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text("Confirm Order"),
  //       content: Text(
  //         "Placing your order for ₹${amountPayable.toStringAsFixed(2)}...",
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () async {
  //             Get.back(); // close dialog first
  //             try {
  //               isLoading.value = true;
  //
  //               // ✅ Build payload automatically
  //               final res = await repo.createShipment(
  //                 vehicleType: "Bike",
  //                 originLat: pLat.value,
  //                 originLng: pLng.value,
  //
  //                 destinationLat: dLat.value,
  //                 destinationLng: dLng.value,
  //                 weight: weight.value,
  //                 weightUnit: selectedWeightUnit.value,
  //                 notes: description.value,
  //                 pickup: {
  //                   "name": pNameController.text,
  //                   "phone": pMobileController.text,
  //                   "address": pAddress.value,
  //                   "latitude": pLat.value,
  //                   "longitude": pLng.value,
  //                 },
  //                 dropoff: {
  //                   "name": dnameController.text,
  //                   "phone": dmobileController.text,
  //                   "address": dAddress.value,
  //                   "latitude": dLat.value,
  //                   "longitude": dLng.value,
  //                 },
  //                 collectType: selectedTime.value == 0 ? "immediate" : "scheduled",
  //                 scheduledAt: selectedTime.value == 1 ? scheduledDateTime.value : null,
  //                 imageUrls: selectedImages.isNotEmpty
  //                     ? selectedImages.map((x) => x.path).toList()
  //                     : null,
  //               );
  //
  //               // debugPrint("✅ Shipment API Response: $res");
  //
  //               isLoading.value = false;
  //
  //               if (res.containsKey('error')) {
  //                 Get.snackbar("Error", res['error'].toString(),
  //                     snackPosition: SnackPosition.BOTTOM,
  //                     backgroundColor: Colors.red,
  //                     colorText: Colors.white);
  //                 return;
  //               }
  //
  //               // --- SAFE EXTRACTION: check shipment first, then top-level keys ---
  //               final shipment = (res['shipment'] is Map) ? Map<String, dynamic>.from(res['shipment']) : null;
  //
  //               final clientSecretFromShipment = shipment != null ? (shipment['clientSecret']?.toString() ?? '') : '';
  //               final clientSecretTopLevel = res['clientSecret']?.toString() ?? '';
  //               shipmentClientSecret.value = clientSecretTopLevel.isNotEmpty ? clientSecretTopLevel : clientSecretFromShipment;
  //
  //               final intentFromShipment = shipment != null ? (shipment['stripePaymentIntentId']?.toString() ?? '') : '';
  //               final intentTopLevel = res['stripePaymentIntentId']?.toString() ?? '';
  //               stripePaymentIntentId.value = intentTopLevel.isNotEmpty ? intentTopLevel : intentFromShipment;
  //
  //               // DEBUG logs to confirm values
  //               debugPrint("Extracted clientSecret: ${shipmentClientSecret.value}");
  //               debugPrint("Extracted stripePaymentIntentId: ${stripePaymentIntentId.value}");
  //
  //               // If client secret absent, show error
  //               if (shipmentClientSecret.value.isEmpty) {
  //                 Get.snackbar("Error", "Payment details missing (clientSecret).",
  //                     snackPosition: SnackPosition.BOTTOM,
  //                     backgroundColor: Colors.red,
  //                     colorText: Colors.white);
  //                 return;
  //               }
  //
  //               Get.toNamed(AppRoutes.payment);
  //             } catch (e) {
  //               isLoading.value = false;
  //               Get.snackbar('Error', e.toString(),
  //                   snackPosition: SnackPosition.BOTTOM,
  //                   backgroundColor: Colors.red,
  //                   colorText: Colors.white);
  //             }
  //           },
  //
  //           child: const Text("OK"),
  //         ),
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: const Text("Cancel"),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  // ---- NEW: Apply LocationController data into pickup fields ----
  void _applyPickupFromLocation() {
    final LatLng? pos = locationController.currentPosition.value;
    final String address = locationController.currentAddress.value ?? '';

    // If neither address nor pos available, do nothing
    if ((address.isEmpty || address == 'loading_location'.tr) && pos == null)
      return;

    // Fill reactive pickup address and coords
    if (address.isNotEmpty && address != 'loading_location'.tr) {
      // Best-effort parsing
      pAddress.value = address;
      try {
        final parts = address.split(',');
        if (parts.isNotEmpty) {
          pLocality.value = parts[1].trim();
        }

        // try to find pincode in the address parts (simple regex)
        final pincodeRegex = RegExp(r'\b\d{6}\b');
        final match = pincodeRegex.firstMatch(address);
        if (match != null && pPincodeController.text.isEmpty) {
          pPincodeController.text = match.group(0) ?? '';
        }
      } catch (_) {
        // ignore parsing errors
      }
    }

    if (pos != null) {
      pLat.value = pos.latitude;
      pLng.value = pos.longitude;
    }

    // If we have current user info, prefill name & mobile (if empty)
    if (currentUser.value != null) {
      if (pNameController.text.trim().isEmpty &&
          (currentUser.value!.name?.isNotEmpty ?? false)) {
        pNameController.text = currentUser.value!.name!;
      }
      if (pMobileController.text.trim().isEmpty &&
          (currentUser.value!.mobile?.isNotEmpty ?? false)) {
        pMobileController.text = currentUser.value!.mobile!;
      }
    }

    // Recompute derived pickup address string & validate form
    updatePickUpReactive();
    validatePickupForm();
    update(); // update UI listeners
  }

  Future<void> useCurrentLocationAsPickup() async {
    // If location is still loading, show message
    if (locationController.currentAddress.value == 'loading_location'.tr) {
      Get.snackbar(
        "info".tr,
        "please_wait_getting_location".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _applyPickupFromLocation();
    Get.snackbar(
      "success".tr,
      "pickup_set_to_current_location".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();

    // Drop-off listeners
    dnameController.addListener(validateDropOffForm);
    dmobileController.addListener(validateDropOffForm);
    dlankmarkController.addListener(validateDropOffForm);
    dpincodeController.addListener(validateDropOffForm);
    ever(dselectedAddressType, (_) => validateDropOffForm());

    // Pickup listeners
    pNameController.addListener(validatePickupForm);
    pMobileController.addListener(validatePickupForm);
    pLandMarkController.addListener(validatePickupForm);
    pPincodeController.addListener(validatePickupForm);
    ever(pselectedAddressType, (_) => validatePickupForm());

    // --- NEW: react to LocationController updates ---
    ever(locationController.currentAddress, (_) {
      _applyPickupFromLocation();
    });

    ever(locationController.currentPosition, (_) {
      _applyPickupFromLocation();
    });

    // apply immediately if available
    _applyPickupFromLocation();
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
    mapController?.dispose();
    super.onClose();
  }
}
