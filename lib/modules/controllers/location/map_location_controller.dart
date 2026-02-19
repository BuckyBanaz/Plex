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
    try {
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
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showToast(message: "location_permission_denied_forever".tr);
        isLoading.value = false;
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10), // Add timeout
        );
      } catch (e) {
        debugPrint('Error getting current position: $e');
        // Try to get last known position as fallback
        position = await Geolocator.getLastKnownPosition();
      }

      // Validate position is available
      if (position == null) {
        debugPrint('No position available (current or last known)');
        isLoading.value = false;
        return;
      }

      // Use position (guaranteed non-null at this point)
      currentLatLng.value = LatLng(position.latitude, position.longitude);
      await _updateAddress(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error in _determinePosition: $e');
      // Don't crash, just set loading to false
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update address from coordinates
  Future<void> _updateAddress(double lat, double lng) async {
    try {
      isConfirming.value = true; // ⬅️ Start loading
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      // Check if placemarks list is not empty
      if (placemarks.isEmpty) {
        address.value = "unknown_location".tr;
        fullAddress.value = "unknown_location".tr;
        pincode.value = '';
        return;
      }
      
      Placemark place = placemarks.first;
      address.value = "${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}";
      fullAddress.value =
      "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
      pincode.value = place.postalCode ?? '';
    } catch (e) {
      debugPrint('Error updating address: $e');
      address.value = "unknown_location".tr;
      fullAddress.value = "unknown_location".tr;
      pincode.value = '';
    } finally {
      isConfirming.value = false; // ⬅️ Stop loading
    }
  }


  /// ✅ Camera move handler
  void onCameraMove(CameraPosition position) {
    currentLatLng.value = position.target;
  }

  Future<void> onCameraIdle() async {
    try {
      await _updateAddress(currentLatLng.value.latitude, currentLatLng.value.longitude);
      _sessionToken = _generateSessionToken();
    } catch (e) {
      debugPrint('Error in onCameraIdle: $e');
      // Don't crash, just log the error
    }
  }

  /// 🔍 Debounced search handler
  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.isEmpty) {
        suggestions.clear();
        return;
      }
      try {
        // Ensure sessionToken is not null
        if (_sessionToken == null) {
          _sessionToken = _generateSessionToken();
        }
        suggestions.value = await _mapRepository.getSuggestions(value, _sessionToken!);
      } catch (e) {
        debugPrint('Error in onSearchChanged: $e');
        suggestions.clear();
      }
    });
  }

  /// 📍 Handle suggestion selection
  Future<void> selectSuggestion(Map<String, dynamic> suggestion) async {
    try {
      final placeId = suggestion['place_id'];
      if (placeId == null) return;

      searchController.text = suggestion['description'] ?? "";
      suggestions.clear();

      // Ensure sessionToken is not null
      if (_sessionToken == null) {
        _sessionToken = _generateSessionToken();
      }

      final details = await _mapRepository.getPlaceDetails(placeId, _sessionToken!);
      if (details != null) {
        final lat = (details['lat'] as double?) ?? 0.0;
        final lng = (details['lng'] as double?) ?? 0.0;

        // Validate coordinates
        if (lat == 0.0 && lng == 0.0) {
          debugPrint('Invalid coordinates from place details');
          return;
        }

        try {
          // Check if mapController is completed before using it
          if (!mapController.isCompleted) {
            debugPrint('Map controller not ready yet');
            // Wait a bit for map to initialize
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          if (mapController.isCompleted) {
            final mapCtrl = await mapController.future;
            await mapCtrl.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
          }
        } catch (e) {
          debugPrint('selectSuggestion animateCamera error: $e');
        }

        await _updateAddress(lat, lng);
        _sessionToken = _generateSessionToken();
      }
    } catch (e) {
      debugPrint('Error in selectSuggestion: $e');
      // Don't crash, just log the error
    }
  }
}
