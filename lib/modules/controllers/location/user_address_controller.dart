import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plex_user/models/user_models.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';

import '../../../services/domain/service/app/app_service_imports.dart';
import 'location_permission_controller.dart';
import 'package:plex_user/routes/appRoutes.dart';

class UserAddressController extends GetxController {
  // Repositories / Services
  final MapRepository mapRepository = Get.find<MapRepository>();
  final UserRepository userRepository = Get.find<UserRepository>();
  final DatabaseService db = Get.find<DatabaseService>();

  // Location controller (permission + current position stream)
  final LocationController location = Get.put(LocationController());

  // User & addresses
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<AddressModel> savedAddresses = <AddressModel>[].obs;

  // Map related
  Completer<GoogleMapController> mapControllerCompleter = Completer();
  GoogleMapController? get mapController => mapControllerCompleter.isCompleted ? mapControllerCompleter.future as GoogleMapController? : null;
  final Rx<LatLng> initialLocation = const LatLng(28.99, 76.58).obs;
  final Rx<LatLng> pinnedLocation = const LatLng(28.99, 76.58).obs;

  // UI state
  final RxBool isLoadingAddress = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedAddress = 'Moving pin...'.obs;
  final RxString selectedLocality = ''.obs;
  final TextEditingController landmarkController = TextEditingController();
  final RxString selectedAddressType = 'Home'.obs;

  // Search related (copied from MapLocationController)
  final TextEditingController searchController = TextEditingController();
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;
  Timer? _debounce;
  String? _sessionToken;

  // Extra states for deletion
  final RxBool isDeleting = false.obs;

  final RxBool isFetchingLocation = false.obs;
  final RxString currentLocationAddress = 'fetching_location'.tr.obs;

  Timer? _pinDebounce;

  @override
  void onInit() {
    super.onInit();

    _sessionToken = _generateSessionToken();

    // Bind current address stream from LocationController if available
    try {
      currentLocationAddress.bindStream(location.currentAddress.stream);
    } catch (_) {}

    // Initialize user data and saved addresses
    _loadUserData();

    // If LocationController already has a position, use it to initialize map
    if (location.currentPosition.value != null) {
      initialLocation.value = location.currentPosition.value!;
      pinnedLocation.value = location.currentPosition.value!;
    }

    // Kick off fetching live location if needed
    fetchCurrentLocation();

    // Also fetch addresses from API and persist locally
    fetchAndStoreUserAddresses();
  }

  @override
  void onClose() {
    landmarkController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    _pinDebounce?.cancel();
    super.onClose();
  }

  String _generateSessionToken() {
    final rnd = Random();
    return "${DateTime.now().millisecondsSinceEpoch}_${rnd.nextInt(99999)}";
  }

  /* ------------------------- User Data & Saved Addresses ------------------------- */
  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;

      final UserModel? userData = db.user;
      if (userData != null) {
        currentUser.value = userData;

        if (currentUser.value?.address.isNotEmpty ?? false) {
          savedAddresses.assignAll(currentUser.value!.address);
        }
      }
    } catch (e) {
      debugPrint('Failed to load User data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAndStoreUserAddresses() async {
    try {
      isLoading.value = true;
      final res = await userRepository.getUserAddresses(); // returns List<AddressModel>

      // if the repository returns a List<AddressModel> use it directly
      final List<AddressModel> parsed = res is List<AddressModel>
          ? res
          : _parseAddressesFromResponse(res);

      savedAddresses.assignAll(parsed);
      await _updateLocalUserWithAddresses(parsed);
      debugPrint('User addresses fetched and stored locally. Count: ${parsed.length}');
    } catch (e) {
      debugPrint('fetchAndStoreUserAddresses failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<AddressModel> _parseAddressesFromResponse(dynamic res) {
    final List<AddressModel> parsed = [];

    try {
      if (res == null) return parsed;

      // The API returns { data: [...] }
      if (res is Map && res.containsKey('data')) {
        final data = res['data'];
        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              parsed.add(AddressModel.fromJson(item));
            } else if (item is Map) {
              parsed.add(AddressModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      }
      // Or directly returns a list
      else if (res is List) {
        for (final item in res) {
          parsed.add(AddressModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } catch (e) {
      debugPrint('Error parsing addresses: $e');
    }

    return parsed;
  }

  Future<void> _updateLocalUserWithAddresses(List<AddressModel> addresses) async {
    try {
      final existing = db.user;
      if (existing != null) {
        final updated = UserModel(
          id: existing.id,
          name: existing.name,
          email: existing.email,
          userType: existing.userType,
          mobile: existing.mobile,
          mobileVerified: existing.mobileVerified,
          emailVerified: existing.emailVerified,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
          address: addresses,
        );
        await db.putUser(updated);
        currentUser.value = updated;
      } else {
        // If no existing user in DB, create a minimal user object and save
        final now = DateTime.now();
        final newUser = UserModel(
          id: addresses.isNotEmpty ? (addresses.first.id ?? 0) : 0,
          name: '',
          email: '',
          userType: '',
          mobile: '',
          mobileVerified: false,
          emailVerified: false,
          createdAt: now,
          updatedAt: now,
          address: addresses,
        );
        await db.putUser(newUser);
        currentUser.value = newUser;
      }
    } catch (e) {
      debugPrint('Failed to update local user with addresses: $e');
    }
  }

  void selectSavedAddress(AddressModel address) {
    Get.back();
    Get.snackbar('address_selected'.tr, '${address.addressAs}: ${address.address}');
  }

  void editAddress(AddressModel address) {
    Get.snackbar('Edit', 'Editing address: ${address.addressAs}');
    // TODO: Implement edit flow (navigate to edit screen with address)
  }

  Future<void> deleteAddress(AddressModel address) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('No')),
          TextButton(onPressed: () => Get.back(result: true), child: Text('Yes')),
        ],
      ),
    );

    if (shouldDelete != true) return;

    if (address.id != null) {
      try {
        isDeleting.value = true;
        final bool success = await userRepository.deleteUserAddress(id: address.id!);

        if (success) {
          await fetchAndStoreUserAddresses();
          Get.snackbar('Deleted', 'Address ${address.addressAs} removed');
        } else {
          savedAddresses.remove(address);
          await _updateLocalUserWithAddresses(savedAddresses);
          Get.snackbar('Deleted (local)', 'Address removed locally (server delete failed)');
        }
      } catch (e) {
        debugPrint('deleteAddress failed (server): $e');
        savedAddresses.remove(address);
        await _updateLocalUserWithAddresses(savedAddresses);
        Get.snackbar('Deleted (local)', 'Address removed locally (server error)');
      } finally {
        isDeleting.value = false;
      }
    } else {
      savedAddresses.remove(address);
      await _updateLocalUserWithAddresses(savedAddresses);
      Get.snackbar('Deleted', 'Address ${address.addressAs} removed (local)');
    }
  }

  /* ------------------------- Map & Pin Handling ------------------------- */
  void onMapCreated(GoogleMapController controller) {
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(controller);
    } else {
      // already completed, but keep reference if needed
    }
    animateToLocation(initialLocation.value);
    _fetchAddressForPin();
  }

  Future<void> animateToLocation(LatLng locationLatLng) async {
    if (mapControllerCompleter.isCompleted) {
      try {
        final ctrl = await mapControllerCompleter.future;
        await ctrl.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: locationLatLng, zoom: 16.0),
          ),
        );
      } catch (e) {
        debugPrint('animateToLocation error: $e');
      }
    }
  }

  void onCameraMove(CameraPosition position) {
    pinnedLocation.value = position.target;
    isLoadingAddress.value = true;
    selectedAddress.value = 'Moving pin...';
  }

  void onCameraIdle() {
    if (_pinDebounce?.isActive ?? false) _pinDebounce?.cancel();
    _pinDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAddressForPin();
    });
  }

  Future<void> _fetchAddressForPin() async {
    isLoadingAddress.value = true;
    final lat = pinnedLocation.value.latitude;
    final lng = pinnedLocation.value.longitude;

    try {
      final addressData = await mapRepository.getAddressFromCoordinates(lat, lng);

      if (addressData != null) {
        selectedAddress.value = addressData['formatted_address'] ?? 'Could not find address';
        selectedLocality.value = addressData['locality'] ?? 'Unknown Area';
      } else {
        selectedAddress.value = 'Could not find address';
        selectedLocality.value = 'Unknown Area';
      }
    } catch (e) {
      selectedAddress.value = 'Could not find address';
      selectedLocality.value = 'Unknown Area';
      debugPrint('Address fetch failed: $e');
    } finally {
      isLoadingAddress.value = false;
    }
  }

  void onAddressTypeSelected(String type) {
    selectedAddressType.value = type;
  }

  /* ------------------------- Search / Suggestions ------------------------- */

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.isEmpty) {
        suggestions.clear();
        return;
      }
      try {
        final res = await mapRepository.getSuggestions(value, _sessionToken ?? _generateSessionToken());
        // expect List<Map<String,dynamic>>
        if (res is List) {
          suggestions.assignAll(List<Map<String, dynamic>>.from(res));
        } else {
          suggestions.clear();
        }
      } catch (e) {
        debugPrint('getSuggestions failed: $e');
        suggestions.clear();
      }
    });
  }

  Future<void> selectSuggestion(Map<String, dynamic> suggestion) async {
    final placeId = suggestion['place_id'] ?? suggestion['placeId'];
    if (placeId == null) return;

    searchController.text = suggestion['description'] ?? suggestion['formatted'] ?? "";
    suggestions.clear();

    try {
      final details = await mapRepository.getPlaceDetails(placeId, _sessionToken ?? _generateSessionToken());
      if (details != null) {
        final lat = (details['lat'] as double?) ?? (details['latitude'] as double?) ?? 0.0;
        final lng = (details['lng'] as double?) ?? (details['longitude'] as double?) ?? 0.0;

        // animate map
        if (mapControllerCompleter.isCompleted) {
          try {
            final ctrl = await mapControllerCompleter.future;
            await ctrl.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16));
          } catch (e) {
            debugPrint('selectSuggestion animateCamera error: $e');
          }
        }

        // update selected address using reverse geocode
        pinnedLocation.value = LatLng(lat, lng);
        await _fetchAddressForPin();

        _sessionToken = _generateSessionToken();
      }
    } catch (e) {
      debugPrint('selectSuggestion failed: $e');
    }
  }

  /* ------------------------- Save Address (send to backend) ------------------------- */
  Future<void> saveAddress() async {
    if (landmarkController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter address details (Floor, House no.)');
      return;
    }
    if (isSaving.value) return;

    isSaving.value = true;

    try {
      // call API to add address
      await userRepository.addUserAddress(
        address: landmarkController.text,
        addressAs: selectedAddressType.value,
        landmark: selectedAddress.value,
        locality: selectedLocality.value,
        latitude: pinnedLocation.value.latitude,
        longitude: pinnedLocation.value.longitude,
        isDefault: false,
      );

      // After successful API call, refresh addresses from server and persist locally
      await fetchAndStoreUserAddresses();

      isSaving.value = false;
      Get.back();
      Get.snackbar('Success', 'Address saved successfully!');
    } catch (e) {
      isSaving.value = false;
      debugPrint('saveAddress failed: $e');
      Get.snackbar('Error', 'Failed to save address: $e');
    }
  }

  /* ------------------------- Helpers & Navigation ------------------------- */
  void fetchCurrentLocation() async {
    isFetchingLocation.value = true;
    currentLocationAddress.value = 'fetching_location'.tr;

    try {
      // Try to use LocationController's position first
      if (location.currentPosition.value != null) {
        initialLocation.value = location.currentPosition.value!;
        pinnedLocation.value = location.currentPosition.value!;
        currentLocationAddress.value = location.currentAddress.value ?? currentLocationAddress.value;
      } else {
        // Temporary placeholder — change to real lookup when LocationController provides it
        currentLocationAddress.value = 'Puthi Mangal Khan, Hisar';
      }
    } catch (e) {
      debugPrint('fetchCurrentLocation failed: $e');
    } finally {
      isFetchingLocation.value = false;
    }
  }

  void goToAddAddressScreen() {
    Get.toNamed(AppRoutes.addUserAddress);
  }
}
