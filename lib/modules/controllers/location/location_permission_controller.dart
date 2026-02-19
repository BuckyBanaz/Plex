import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import '../../../common/Toast/toast.dart';
import '../../../routes/appRoutes.dart';
import '../../../services/domain/repository/repository_imports.dart';
import '../../../services/domain/service/app/app_service_imports.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';

class LocationController extends GetxController {
  final GeolocationService gl = Get.find<GeolocationService>();
  final DatabaseService db = Get.find<DatabaseService>();
  final UserRepository userRepo = UserRepository();
  StreamSubscription<ServiceStatus>? serviceListener;
  StreamSubscription<Position>? positionStreamSub;
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  var permissionGranted = false;
  var loadingLocation = false;
  var isButtonLoading = false;

  var currentAddress = 'loading_location'.tr.obs;

  // throttle control: minimum duration between API updates
  final Duration minUpdateInterval = const Duration(seconds: 8);
  DateTime? _lastUpdateTime;

  @override
  void onInit() {
    super.onInit();
    serviceListener = Geolocator.getServiceStatusStream().listen(onStatusChanged);
    _checkPermissionAndStartStream();
  }


  // Future<void> refreshToken() async {
  //   try{
  //     await authrepo.refreshToken();
  //   }catch(e){
  //
  //   }
  // }
  @override
  void onClose() {
    _stopPositionStream();
    serviceListener?.cancel();
    super.onClose();
  }

  void _navigateToDashboard() {
    String? userType = db.userType;
    if (userType == 'individual') {
      Get.offAllNamed(AppRoutes.userDashBoard);
    } else if (userType == 'driver') {
      Get.offAllNamed(AppRoutes.driverHome);
    } else {
      Get.offAllNamed(AppRoutes.userDashBoard);
    }
  }

  Future<void> requestPermissionAndNavigate() async {
    isButtonLoading = true;
    update();

    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      await db.putIsLocationScreenShown(true);
      _navigateToDashboard();
      // start stream after permission granted
      await _startPositionStreamIfPermitted();
    } else if (status.isDenied) {
      CustomSnackbar.error(
        "please_grant_location_permission".tr,
        title: "error".tr,
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    isButtonLoading = false;
    update();
  }

  Future<void> skipPermissionAndNavigate() async {
    debugPrint("User chose not to give permission for now.");
    await db.putIsLocationScreenShown(true);
    _navigateToDashboard();
  }

  void _checkPermissionAndStartStream() async {
    permissionGranted = await gl.isPermissionGranted();
    if (permissionGranted) {
      // load cached address & start stream
      await loadCurrentAddress();
      await _startPositionStreamIfPermitted();
    }
    update();
  }

  Future<void> onGrantPermissionTap() async {
    var hasPermission = await gl.getPermission();
    permissionGranted = hasPermission;
    if (permissionGranted) {
      await _startPositionStreamIfPermitted();
      onContinueTap(); // optionally run a one-shot update
    }
  }

  // Called by UI when user chooses to continue (initial run)
  void onContinueTap() async {
    try {
      var position = await gl.determinePosition(
        forceGivePermission: true,
        forceTurnOnLocation: true,
      );

      if (position != null) {
        debugPrint("Location determined. Sending one-shot update via repository...");
        await _sendLocationAndPersist(position);

        await _fetchAndUpdateAddress(position);
      }

      await db.putIsLocationScreenShown(true);

      try { serviceListener?.cancel(); } catch (e) {}

      if (db.userType == 'individual') {
        Get.offAllNamed(AppRoutes.userDashBoard);
      } else if (db.userType == "driver") {
        Get.offAllNamed(AppRoutes.driverDashBoard);
      } else {
        Get.offAllNamed(AppRoutes.userDashBoard);
      }
    } catch (error) {
      currentAddress.value = 'could_not_get_location'.tr;
      showToast(message: error.toString());
    }
  }

  Future<void> loadCurrentAddress() async {
    loadingLocation = true;
    update();
    try {
      var position = await gl.determinePosition(
        forceGivePermission: false,
        forceTurnOnLocation: false,
      );

      if (position != null) {
        await _fetchAndUpdateAddress(position);
      } else {
        currentAddress.value = 'location_not_available'.tr;
      }
    } catch (e) {
      currentAddress.value = 'error_loading_location'.tr;
    } finally {
      loadingLocation = false;
      update();
    }
  }

  Future<void> _fetchAndUpdateAddress(Position position) async {
    try {
      currentPosition.value = LatLng(position.latitude, position.longitude);
      String address = await gl.getAddressFromPosition(position);
      currentAddress.value = address;
    } catch (e) {
      currentAddress.value = 'could_not_find_address'.tr;
      debugPrint('Error getting address: $e');
    } finally {
      update();
    }
  }

  void onStatusChanged(ServiceStatus status) async {
    debugPrint('Service status changed: $status');
    if (status == ServiceStatus.enabled) {
      // start sending location again when service is enabled
      await _startPositionStreamIfPermitted();

      await loadCurrentAddress();
    } else {
      // when disabled, stop stream to save resources
      _stopPositionStream();
    }
  }

  // -------------------------
  // Position stream management
  // -------------------------
  Future<void> _startPositionStreamIfPermitted() async {
    try {
      permissionGranted = await gl.isPermissionGranted();
      if (!permissionGranted) {
        debugPrint('Location permission not granted - not starting stream.');
        return;
      }

      // If already started, no-op
      if (positionStreamSub != null) {
        debugPrint('Position stream already active.');
        return;
      }

      // Configure location settings (adjust for platform if needed)
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters - change as required
        timeLimit: null,
      );

      positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) async {
          debugPrint('Position stream update: ${position.latitude}, ${position.longitude}');

          // Throttle by minUpdateInterval
          final now = DateTime.now();
          if (_lastUpdateTime != null && now.difference(_lastUpdateTime!) < minUpdateInterval) {
            debugPrint('Skipping update due to throttle.');
            return;
          }
          _lastUpdateTime = now;

          await _sendLocationAndPersist(position);
        },
        onError: (err) {
          debugPrint('Position stream error: $err');
        },
        cancelOnError: false,
      );

      debugPrint('Position stream started.');
    } catch (e) {
      debugPrint('Error starting position stream: $e');
    }
  }

  void _stopPositionStream() {
    try {
      positionStreamSub?.cancel();
      positionStreamSub = null;
      debugPrint('Position stream stopped.');
    } catch (e) {
      debugPrint('Error stopping position stream: $e');
    }
  }

  // -------------------------
  // Send to API & persist
  // -------------------------
  Future<void> _sendLocationAndPersist(Position position) async {
    try {
      currentPosition.value = LatLng(position.latitude, position.longitude);
      // Ensure apiKey exists
      final apiKey = db.apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('API key missing in DB - not sending location.');
        return;
      }

      // Call repository (which calls API)
      final result = await userRepo.updateUserLocation(position);

      // result is void in your repo - assuming successful if no exception.
      // Persist last-known-location as JSON string (latitude,long,timestamp,...)
      final locationJson = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'heading': position.heading,
        'speed': position.speed,
        'recorded_at': position.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      await db.putLastKnownLocation(locationJson.toString());
      debugPrint('Last known location saved to DB.');

    } catch (e) {
      debugPrint('Failed to send location: $e');
    }
  }




}
