import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plex_user/common/Toast/toast.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';

class MapLocationController extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  final MapRepository _mapRepository = MapRepository();

  var currentLatLng = const LatLng(26.9124, 75.7873).obs;
  var address = ''.obs;
  var fullAddress = ''.obs;
  var pincode = ''.obs;
  var isLoading = true.obs;
  var isConfirming = false.obs;

  final TextEditingController searchController = TextEditingController();
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;

  Timer? _debounce;
  String? _sessionToken;

  @override
  void onInit() {
    super.onInit();
    _sessionToken = _generateSessionToken();
    _determinePosition();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  String _generateSessionToken() {
    final rnd = Random();
    return "${DateTime.now().millisecondsSinceEpoch}_${rnd.nextInt(99999)}";
  }

  /// ✅ Get current location
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast(message: "location_error_enable_service".tr);

      isLoading.value = false;
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast(message: "location_permission_denied".tr);
        // Get.snackbar("Error", "Location permissions are denied");
        isLoading.value = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showToast(message: "location_permission_denied_forever".tr);
      // Get.snackbar("Error", "Location permission permanently denied.");
      isLoading.value = false;
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentLatLng.value = LatLng(position.latitude, position.longitude);
    await _updateAddress(position.latitude, position.longitude);
    isLoading.value = false;
  }

  /// ✅ Update address from coordinates
  Future<void> _updateAddress(double lat, double lng) async {
    try {
      isConfirming.value = true; // ⬅️ Start loading
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks.first;
      address.value = "${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}";
      fullAddress.value =
      "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
      pincode.value = place.postalCode ?? '';
    } catch (e) {
      address.value = "unknown_location".tr;
    } finally {
      isConfirming.value = false; // ⬅️ Stop loading
    }
  }


  /// ✅ Camera move handler
  void onCameraMove(CameraPosition position) {
    currentLatLng.value = position.target;
  }

  Future<void> onCameraIdle() async {
    await _updateAddress(currentLatLng.value.latitude, currentLatLng.value.longitude);
    _sessionToken = _generateSessionToken();
  }

  /// 🔍 Debounced search handler
  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.isEmpty) {
        suggestions.clear();
        return;
      }
      suggestions.value = await _mapRepository.getSuggestions(value, _sessionToken!);
    });
  }

  /// 📍 Handle suggestion selection
  Future<void> selectSuggestion(Map<String, dynamic> suggestion) async {
    final placeId = suggestion['place_id'];
    if (placeId == null) return;

    searchController.text = suggestion['description'] ?? "";
    suggestions.clear();

    final details = await _mapRepository.getPlaceDetails(placeId, _sessionToken!);
    if (details != null) {
      final lat = (details['lat'] as double?) ?? 0.0;
      final lng = (details['lng'] as double?) ?? 0.0;


      final mapCtrl = await mapController.future;
      mapCtrl.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));

      await _updateAddress(lat, lng);
      _sessionToken = _generateSessionToken();
    }
  }
}
