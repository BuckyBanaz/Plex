import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plex_user/models/user_models.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';

import '../../../services/domain/service/app/app_service_imports.dart';
import 'location_permission_controller.dart';


class AddNewAddressController extends GetxController {
  // Dependencies
  final MapRepository mapRepository = Get.find<MapRepository>();
  final UserRepository userRepository = Get.find<UserRepository>();
  final LocationController locationController = Get.find<LocationController>();
  final DatabaseService db = Get.find<DatabaseService>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  // Map
  GoogleMapController? mapController;
  final Rx<LatLng> initialLocation = const LatLng(28.99, 76.58).obs;
  final Rx<LatLng> pinnedLocation = const LatLng(28.99, 76.58).obs;

  final RxBool isLoadingAddress = true.obs;
  final RxBool isSaving = false.obs;
  final RxString selectedAddress = 'Moving pin...'.obs;
  final RxString selectedLocality = ''.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController landmarkController = TextEditingController();

  final RxString selectedAddressType = 'Home'.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();

    if (locationController.currentPosition.value != null) {
      initialLocation.value = locationController.currentPosition.value!;
      pinnedLocation.value = locationController.currentPosition.value!;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    animateToLocation(initialLocation.value);
    _fetchAddressForPin();
  }

  void animateToLocation(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 16.0),
      ),
    );
  }

  void onCameraMove(CameraPosition position) {
    pinnedLocation.value = position.target;
    isLoadingAddress.value = true;
    selectedAddress.value = 'Moving pin...';
  }

  void onCameraIdle() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAddressForPin();
    });
  }

  Future<void> _fetchAddressForPin() async {
    isLoadingAddress.value = true;
    final lat = pinnedLocation.value.latitude;
    final lng = pinnedLocation.value.longitude;

    final addressData = await mapRepository.getAddressFromCoordinates(lat, lng);

    if (addressData != null) {
      selectedAddress.value = addressData['formatted_address'] ?? 'Could not find address';
      selectedLocality.value = addressData['locality'] ?? 'Unknown Area';
    } else {
      selectedAddress.value = 'Could not find address';
      selectedLocality.value = 'Unknown Area';
    }
    isLoadingAddress.value = false;
  }

  void onAddressTypeSelected(String type) {
    selectedAddressType.value = type;
  }

  Future<void> saveAddress() async {
    if (landmarkController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter address details (Floor, House no.)');
      return;
    }
    if (isSaving.value) return;

    isSaving.value = true;

    try {
      await userRepository.addUserAddress(
        address: landmarkController.text,
        addressAs: selectedAddressType.value,
        landmark: selectedAddress.value,
        locality: selectedLocality.value,
        latitude: pinnedLocation.value.latitude,
        longitude: pinnedLocation.value.longitude,
        isDefault: false,
        langKey: 1,
      );

      isSaving.value = false;
      Get.back();
      Get.snackbar('Success', 'Address saved successfully!');

    } catch (e) {
      isSaving.value = false;
      Get.snackbar('Error', 'Failed to save address: $e');
    }
  }

}