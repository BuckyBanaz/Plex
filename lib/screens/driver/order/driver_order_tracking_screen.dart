import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/constant/api_endpoint.dart';

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/Toast/toast.dart';
import '../../../services/domain/repository/repository_imports.dart';
import '../../../services/domain/service/app/app_service_imports.dart';
import '../../widgets/helpers.dart';
import 'prickup_verification_screen.dart';
import 'dropoff_verification_screen.dart';

enum DeliveryStage { toPickup, startRide, toDropoff, completed }

class DriverOrderTrackingController extends GetxController {
  late Map<String, dynamic> shipment;
  final Rx<DeliveryStage> stage = DeliveryStage.toPickup.obs;
  final RxInt etaMinutes = 5.obs;
  final RxBool isActionButtonEnabled = false.obs;
  final RxString actionButtonText = 'Start Pick Up'.obs;
  final RxDouble driverBearing = 0.0.obs; // For rotation
  
  // Loading state for smooth transition
  final RxBool isMapReady = false.obs;
  final RxBool isLocationLoading = true.obs;

  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  late LatLng pickupLatLng;
  late LatLng dropoffLatLng;
  LatLng? currentLatLng;
  final double arrivalThreshold = 1000000; // 100m for dropoff
  final String googleApiKey = "AIzaSyAoVauo0szWOaKCsNW6lqklZCXmZED-7ZU";
  late final PolylinePoints polylinePointsDecoder;
  List<LatLng> _routePoints = [];
  static const double _driverIconRotationOffset = 0.0;

  // Timer for periodic updates
  Timer? _locationUpdateTimer;
  final ShipmentRepository _repo = Get.find<ShipmentRepository>();

  // SVG Bitmaps
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? dropoffIcon;

  @override
  void onInit() {
    super.onInit();
    polylinePointsDecoder = PolylinePoints(apiKey: googleApiKey);
    shipment = Get.arguments['shipment'] ?? {};
    
    // 🚀 INSTANT: Check if location was passed from previous screen
    final passedLat = Get.arguments['currentLat'];
    final passedLng = Get.arguments['currentLng'];
    final passedHeading = Get.arguments['heading'];
    
    if (passedLat != null && passedLng != null) {
      currentLatLng = LatLng(passedLat as double, passedLng as double);
      driverBearing.value = (passedHeading as double?) ?? 0.0;
      isLocationLoading.value = false; // No loading needed!
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ ⚡ INSTANT LOCATION from previous screen!');
      debugPrint('║ Location: $currentLatLng');
      debugPrint('╚══════════════════════════════════════════════════════════════');
    }
    
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚀 DRIVER TRACKING SCREEN INIT');
    debugPrint('║ Shipment: $shipment');
    debugPrint('║ Has passed location: ${currentLatLng != null}');
    debugPrint('╚══════════════════════════════════════════════════════════════');
    
    // Initialize stage based on shipment status
    _initializeStageFromStatus();
    
    // Initialize locations first (without markers)
    _initLocationsOnly();
    
    // Load icons and setup markers - faster if we have location
    _initializeAsync();
    
    // Then sync every 10 seconds
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _syncLocationToServer(),
    );
  }
  
  /// Separate async initialization to ensure proper sequencing
  Future<void> _initializeAsync() async {
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚀 _initializeAsync START');
    debugPrint('║ Already have location: ${currentLatLng != null}');
    
    // 1. Load custom icons (in parallel)
    _loadCustomIcons();
    debugPrint('║ ⏳ Icons loading in background...');
    
    // 2. If we already have location (passed from previous screen), show everything INSTANTLY
    if (currentLatLng != null) {
      debugPrint('║ ⚡ INSTANT MODE - Using pre-fetched location');
      
      // Show all markers immediately
      _updateMarkersForStage();
      debugPrint('║ ✅ Markers added instantly');
      
      // Fit camera to show both markers
      _fitCameraToIncludeCurrent();
      
      // Update route in background
      _updateRoute();
      
      // Check arrival
      _checkArrival();
      debugPrint('║ ✅ Button enabled: ${isActionButtonEnabled.value}');
      
    } else {
      // 3. No pre-fetched location - need to fetch (old flow)
      debugPrint('║ 🔄 FETCH MODE - Getting location...');
      
      // Show destination marker immediately
      _addDestinationMarkerImmediate();
      _animateCameraToDestination();
      
      // Fetch location
      isLocationLoading.value = true;
      await _requestInitialLocationAsync();
      isLocationLoading.value = false;
      debugPrint('║ ✅ Location fetched: $currentLatLng');
      
      // Update markers with driver
      _updateMarkersForStage();
      
      // Update route
      await _updateRoute();
      
      // Check arrival
      _checkArrival();
      
      // Fit camera
      _fitCameraToIncludeCurrent();
    }
    
    // Always start location listener
    _listenToLocation();
    debugPrint('║ ✅ Location listener started');
    
    // Sync location to server
    _syncLocationToServer();
    
    debugPrint('║ 🏁 _initializeAsync COMPLETE');
    debugPrint('╚══════════════════════════════════════════════════════════════');
    
    update(['map']);
  }
  
  /// Add destination marker immediately without waiting for icons
  void _addDestinationMarkerImmediate() {
    final isToPickup = stage.value == DeliveryStage.toPickup;
    final targetLatLng = isToPickup ? pickupLatLng : dropoffLatLng;
    final markerTitle = isToPickup ? 'Pickup' : 'Dropoff';
    final markerId = isToPickup ? 'pickup' : 'dropoff';
    final hue = isToPickup ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed;
    
    markers.add(Marker(
      markerId: MarkerId(markerId),
      position: targetLatLng,
      infoWindow: InfoWindow(title: markerTitle),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
    ));
    markers.refresh();
  }
  
  /// Animate camera to destination immediately
  void _animateCameraToDestination() {
    final isToPickup = stage.value == DeliveryStage.toPickup;
    final targetLatLng = isToPickup ? pickupLatLng : dropoffLatLng;
    
    // Will be called when map is ready via onMapCreated
    Future.delayed(const Duration(milliseconds: 500), () {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(targetLatLng, 15),
      );
    });
  }
  
  /// Initialize locations without setting up markers
  void _initLocationsOnly() {
    final pickup = shipment['pickup'];
    final dropoff = shipment['dropoff'];
    
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 📍 INITIALIZING LOCATIONS');
    debugPrint('║ Pickup raw: $pickup');
    debugPrint('║ Dropoff raw: $dropoff');
    
    if (pickup == null || dropoff == null) {
      debugPrint('║ ❌ ERROR: pickup or dropoff is null!');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      // Set default coordinates to prevent crashes
      pickupLatLng = const LatLng(0, 0);
      dropoffLatLng = const LatLng(0, 0);
      return;
    }
    
    // Try multiple field names for coordinates
    double pickupLat = 0.0;
    double pickupLng = 0.0;
    double dropoffLat = 0.0;
    double dropoffLng = 0.0;
    
    // Pickup coordinates
    if (pickup['latitude'] != null) {
      pickupLat = (pickup['latitude'] as num).toDouble();
    } else if (pickup['lat'] != null) {
      pickupLat = (pickup['lat'] as num).toDouble();
    }
    if (pickup['longitude'] != null) {
      pickupLng = (pickup['longitude'] as num).toDouble();
    } else if (pickup['lng'] != null) {
      pickupLng = (pickup['lng'] as num).toDouble();
    }
    
    // Dropoff coordinates
    if (dropoff['latitude'] != null) {
      dropoffLat = (dropoff['latitude'] as num).toDouble();
    } else if (dropoff['lat'] != null) {
      dropoffLat = (dropoff['lat'] as num).toDouble();
    }
    if (dropoff['longitude'] != null) {
      dropoffLng = (dropoff['longitude'] as num).toDouble();
    } else if (dropoff['lng'] != null) {
      dropoffLng = (dropoff['lng'] as num).toDouble();
    }
    
    pickupLatLng = LatLng(pickupLat, pickupLng);
    dropoffLatLng = LatLng(dropoffLat, dropoffLng);
    
    debugPrint('║ ✅ Pickup LatLng: $pickupLatLng');
    debugPrint('║ ✅ Dropoff LatLng: $dropoffLatLng');
    debugPrint('╚══════════════════════════════════════════════════════════════');
  }
  
  /// Async version of initial location request - uses Geolocator directly
  Future<void> _requestInitialLocationAsync() async {
    try {
      debugPrint('║ 📍 Requesting location...');
      
      // Check permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('║ ❌ Location permission denied forever');
        return;
      }
      
      // Get current position directly using Geolocator
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      currentLatLng = LatLng(position.latitude, position.longitude);
      driverBearing.value = position.heading;
      debugPrint('║ ✅ Got location: $currentLatLng');
    } catch (e) {
      debugPrint('║ ❌ Error getting initial location: $e');
      // Try last known position as fallback
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          currentLatLng = LatLng(lastPos.latitude, lastPos.longitude);
          debugPrint('║ ✅ Using last known location: $currentLatLng');
        }
      } catch (_) {}
    }
  }
  
  /// Initialize stage based on shipment status from backend
  void _initializeStageFromStatus() {
    // Handle both string status and OrderStatus enum
    String status;
    final rawStatus = shipment['status'];
    
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚀 INITIALIZING STAGE FROM STATUS');
    debugPrint('║ Raw Status: $rawStatus');
    debugPrint('║ Raw Status Type: ${rawStatus.runtimeType}');
    
    if (rawStatus == null) {
      status = 'accepted';
    } else if (rawStatus is String) {
      // Handle both "picked_up" and "OrderStatus.PickedUp" formats
      String rawStr = rawStatus.toLowerCase().replaceAll('_', '').replaceAll('-', '');
      // Extract status after dot if present: "orderstatus.pickedup" -> "pickedup"
      if (rawStr.contains('.')) {
        status = rawStr.split('.').last;
      } else {
        status = rawStr;
      }
      debugPrint('║ String status detected: $rawStr -> $status');
    } else {
      // Handle OrderStatus enum: OrderStatus.InTransit -> "intransit"
      final enumString = rawStatus.toString().toLowerCase();
      debugPrint('║ Enum string: $enumString');
      
      // Extract just the status part: "orderstatus.intransit" -> "intransit"
      if (enumString.contains('.')) {
        status = enumString.split('.').last.replaceAll('_', '');
        debugPrint('║ After split: $status');
      } else {
        status = enumString.replaceAll('_', '');
      }
    }
    
    debugPrint('║ Final Parsed Status: $status');
    
    // Stage logic based on status
    if (status == 'intransit') {
      // In transit - heading to dropoff
      stage.value = DeliveryStage.toDropoff;
      actionButtonText.value = 'Confirm Delivery';
      debugPrint('║ ✅ Stage: toDropoff (in transit to delivery)');
    } else if (status == 'pickedup') {
      // Picked up but not started ride yet - show Start Ride
      stage.value = DeliveryStage.startRide;
      actionButtonText.value = 'Start Ride';
      isActionButtonEnabled.value = true; // Always enabled after pickup
      debugPrint('║ ✅ Stage: startRide (ready to start delivery)');
    } else if (status == 'delivered') {
      stage.value = DeliveryStage.completed;
      actionButtonText.value = 'Delivered';
      isActionButtonEnabled.value = false;
      debugPrint('║ ✅ Stage: completed');
    } else {
      // Driver accepted, heading to pickup (accepted, assigned, or any other)
      stage.value = DeliveryStage.toPickup;
      actionButtonText.value = 'Confirm Pickup';
      debugPrint('║ ✅ Stage: toPickup (heading to pickup) [status=$status]');
    }
    debugPrint('╚══════════════════════════════════════════════════════════════');
  }

  Future<void> _loadCustomIcons() async {
    driverIcon = await _svgToBitmapDescriptor(
      'assets/icons/driver.svg',
      size: 80,
    );
    pickupIcon = await _svgToBitmapDescriptor(
      'assets/icons/pickup_t.svg',
      size: 60,
    );
    dropoffIcon = await _svgToBitmapDescriptor(
      'assets/icons/dropoff.svg',
      size: 60,
    );
    update(['map']);
  }

  Future<BitmapDescriptor> _svgToBitmapDescriptor(
    String asset, {
    required int size,
    Color? tintColor,
  }) async {
    try {
      final pictureInfo = await vg.loadPicture(SvgAssetLoader(asset), null);
      final scale = ui.window.devicePixelRatio;
      final width = (size * scale).toInt();
      final height = (size * scale).toInt();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Background (optional)
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = Colors.transparent,
      );

      // Tint if needed
      if (tintColor != null) {
        canvas.saveLayer(
          null,
          Paint()..colorFilter = ColorFilter.mode(tintColor, BlendMode.srcIn),
        );
      }

      // Scale SVG to fit exactly
      final svgWidth = pictureInfo.size.width;
      final svgHeight = pictureInfo.size.height;
      final scaleX = width / svgWidth;
      final scaleY = height / svgHeight;
      final scaleFactor = math.min(scaleX, scaleY);

      canvas.translate(
        (width - svgWidth * scaleFactor) / 2,
        (height - svgHeight * scaleFactor) / 2,
      );
      canvas.scale(scaleFactor, scaleFactor);
      canvas.drawPicture(pictureInfo.picture);

      if (tintColor != null) canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(width, height);
      pictureInfo.picture.dispose();
      picture.dispose();

      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      debugPrint("SVG Error: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  // _initLocations moved to _initLocationsOnly() above
  
  void _updateMarkersForStage() {
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🗺️ UPDATING MARKERS FOR STAGE: ${stage.value}');
    debugPrint('║ Icons loaded: driver=${driverIcon != null}, pickup=${pickupIcon != null}, dropoff=${dropoffIcon != null}');
    debugPrint('║ Current location: $currentLatLng');
    
    // Clear ALL markers and rebuild fresh
    markers.clear();
    
    // 1. Always add driver marker first (most important)
    if (currentLatLng != null) {
      final driverMarker = Marker(
        markerId: const MarkerId('current'),
        position: currentLatLng!,
        rotation: _applyIconRotation(driverBearing.value),
        icon: driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 100,
      );
      markers.add(driverMarker);
      debugPrint('║ ✅ Added DRIVER marker at: $currentLatLng');
    } else {
      debugPrint('║ ⚠️ No current location - driver marker not added');
    }
    
    // 2. Add destination marker based on stage
    if (stage.value == DeliveryStage.toPickup) {
      // Heading to pickup - show pickup marker
      final pickupMarker = Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLatLng,
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: shipment['pickup']?['address'] ?? '',
        ),
        icon: pickupIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      markers.add(pickupMarker);
      debugPrint('║ ✅ Added PICKUP marker at: $pickupLatLng');
    } else if (stage.value == DeliveryStage.startRide || stage.value == DeliveryStage.toDropoff) {
      // After pickup - show dropoff marker
      final dropoffMarker = Marker(
        markerId: const MarkerId('dropoff'),
        position: dropoffLatLng,
        infoWindow: InfoWindow(
          title: 'Dropoff',
          snippet: shipment['dropoff']?['address'] ?? '',
        ),
        icon: dropoffIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      markers.add(dropoffMarker);
      debugPrint('║ ✅ Added DROPOFF marker at: $dropoffLatLng');
    }
    // completed stage - only driver marker shown
    
    debugPrint('║ Total markers: ${markers.length}');
    debugPrint('╚══════════════════════════════════════════════════════════════');
    
    // Force UI update
    markers.refresh();
    update(['map']);
  }

  // _addPickupMarker and _addDropoffMarker merged into _updateMarkersForStage

  void _updateCurrentMarker(LatLng pos) {
    markers.removeWhere((m) => m.markerId.value == 'current');
    markers.add(
      Marker(
        markerId: MarkerId('current'),
        position: pos,
        rotation: _applyIconRotation(driverBearing.value),
        icon: driverIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 100,
      ),
    );
    markers.refresh();
  }

  // _requestInitialLocation() moved to _requestInitialLocationAsync() above

  StreamSubscription<Position>? _positionStreamSubscription;
  
  void _listenToLocation() {
    // Use Geolocator directly instead of LocationController
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
    
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final LatLng converted = LatLng(position.latitude, position.longitude);
      final oldPos = currentLatLng;
      currentLatLng = converted;
      
      debugPrint('📍 Location update: $converted');

      // Update bearing only if moving; align with route segment when available
      if (oldPos != null &&
          Geolocator.distanceBetween(
                oldPos.latitude,
                oldPos.longitude,
                converted.latitude,
                converted.longitude,
              ) >
              5) {
        if (_routePoints.length >= 2) {
          driverBearing.value = _bearingFromRoute(converted, _routePoints);
        } else {
          driverBearing.value = _calculateBearing(oldPos, converted);
        }
      }

      // Update ALL markers (driver + destination) when location changes
      // This ensures markers appear even if they were missing before
      _updateMarkersForStage();
      _checkArrival();
      _updateRoute();
      update(['map']);
    }, onError: (e) {
      debugPrint('❌ Location stream error: $e');
    });
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final startLat = _toRadians(start.latitude);
    final startLng = _toRadians(start.longitude);
    final endLat = _toRadians(end.latitude);
    final endLng = _toRadians(end.longitude);

    final dLng = endLng - startLng;
    final y = math.sin(dLng) * math.cos(endLat);
    final x =
        math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);
    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  double _bearingFromRoute(LatLng pos, List<LatLng> points) {
    if (points.length < 2) return driverBearing.value;
    int nearest = 0;
    double bestDist = double.infinity;
    for (int i = 0; i < points.length; i++) {
      final d = _distanceBetween(pos, points[i]);
      if (d < bestDist) {
        bestDist = d;
        nearest = i;
      }
    }
    int next = nearest + 1;
    if (next >= points.length) {
      next = nearest > 0 ? nearest - 1 : nearest;
    }
    if (next == nearest) return driverBearing.value;
    return _calculateBearing(points[nearest], points[next]);
  }

  double _distanceBetween(LatLng a, LatLng b) {
    final dx = a.longitude - b.longitude;
    final dy = a.latitude - b.latitude;
    return math.sqrt(dx * dx + dy * dy);
  }

  double _applyIconRotation(double bearing) {
    final rotated = (bearing + _driverIconRotationOffset) % 360;
    return rotated < 0 ? rotated + 360 : rotated;
  }

  void _checkArrival() {
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🎯 CHECK ARRIVAL');
    debugPrint('║ Current stage: ${stage.value}');
    debugPrint('║ Current location: $currentLatLng');
    
    if (currentLatLng == null) {
      debugPrint('║ ⚠️ No current location - cannot check arrival');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      return;
    }
    
    // startRide stage - button always enabled
    if (stage.value == DeliveryStage.startRide) {
      isActionButtonEnabled.value = true;
      debugPrint('║ ✅ startRide stage - Button ENABLED');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      return;
    }
    
    // Completed stage - button disabled
    if (stage.value == DeliveryStage.completed) {
      isActionButtonEnabled.value = false;
      debugPrint('║ ✅ completed stage - Button DISABLED');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      return;
    }
    
    // Determine target based on stage
    final target = stage.value == DeliveryStage.toPickup
        ? pickupLatLng
        : dropoffLatLng;
    
    debugPrint('║ Target: $target');
        
    final distance = Geolocator.distanceBetween(
      currentLatLng!.latitude,
      currentLatLng!.longitude,
      target.latitude,
      target.longitude,
    );
    
    // Use same large threshold for both (for testing) - arrivalThreshold is 1000000m
    // In production, change back to: pickup = 1000m, dropoff = 100m
    final threshold = arrivalThreshold; // Using same threshold for both
    final enabled = distance <= threshold;
    isActionButtonEnabled.value = enabled;
    
    debugPrint('║ Distance: ${distance.toStringAsFixed(1)}m');
    debugPrint('║ Threshold: ${threshold}m');
    debugPrint('║ Button enabled: $enabled');
    debugPrint('╚══════════════════════════════════════════════════════════════');
  }

  void onActionButtonPressed() async {
    if (!isActionButtonEnabled.value) return;
    
    final shipmentId = shipment['id']?.toString() ?? '';
    if (shipmentId.isEmpty) {
      showToast(message: 'Invalid shipment ID');
      return;
    }

    if (stage.value == DeliveryStage.toPickup) {
      // Navigate to Pickup OTP verification screen
      Get.to(() => PickupVerificationScreen(shipment: shipment));
    } else if (stage.value == DeliveryStage.startRide) {
      // Start ride - call start-transit API
      await _startRide(shipmentId);
    } else if (stage.value == DeliveryStage.toDropoff) {
      // Navigate to Dropoff OTP verification screen
      Get.to(() => DeliveryVerificationScreen(shipment: shipment));
    }
  }
  
  Future<void> _startRide(String shipmentId) async {
    try {
      showToast(message: 'Starting ride...');
      
      final dio = Dio();
      final db = Get.find<DatabaseService>();
      dio.options.headers['Authorization'] = 'Bearer ${db.accessToken}';
      
      final response = await dio.post(
        '${ApiEndpoint.baseUrl}/shipments/$shipmentId/start-transit',
      );
      
      if (response.data['success'] == true) {
        showToast(message: 'Ride started! Head to delivery location.');
        
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ 🚗 START RIDE SUCCESS - Updating UI');
        
        // Update stage
        stage.value = DeliveryStage.toDropoff;
        actionButtonText.value = 'Confirm Delivery';
        etaMinutes.value = 15;
        
        // Get fresh location before updating markers
        if (currentLatLng == null) {
          debugPrint('║ ⚠️ currentLatLng is null - fetching fresh location...');
          await _requestInitialLocationAsync();
        }
        
        debugPrint('║ Stage updated to: ${stage.value}');
        debugPrint('║ Current location: $currentLatLng');
        debugPrint('║ Dropoff location: $dropoffLatLng');
        
        // Update markers - hide pickup, show dropoff + driver
        _updateMarkersForStage();
        
        // Draw route to dropoff
        await _updateRoute();
        _fitCameraToIncludeCurrent();
        
        // Check if already at dropoff location
        _checkArrival();
        
        debugPrint('║ Markers count after update: ${markers.length}');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        
        update(['map']);
      } else {
        showToast(message: response.data['message'] ?? 'Failed to start ride');
      }
    } catch (e) {
      debugPrint('Start ride error: $e');
      showToast(message: 'Failed to start ride');
    }
  }
  
  Future<void> _updateRoute() async {
    if (currentLatLng == null) return;
    
    // Don't draw route during startRide stage (waiting to start)
    if (stage.value == DeliveryStage.startRide) {
      polylines.clear();
      _routePoints.clear();
      return;
    }
    
    final origin = currentLatLng!;
    final destination = stage.value == DeliveryStage.toPickup
        ? pickupLatLng
        : dropoffLatLng;

    try {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$googleApiKey'
          '&mode=driving';

      final response = await Dio().get(url);
      if (response.data['status'] != 'OK') return;

      final route = response.data['routes'][0];
      final polylineEncoded = route['overview_polyline']['points'];
      final leg = route['legs'][0];
      final durationText = leg['duration']['text'] as String? ?? '';
      int minutes = _parseDurationToMinutes(durationText);
      etaMinutes.value = minutes > 0 ? minutes : 5;

      final List<PointLatLng> decoded = PolylinePoints.decodePolyline(
        polylineEncoded,
      );
      final List<LatLng> points = decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
      _routePoints = points;

      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: points,
          color: AppColors.primary,
          width: 6,
        ),
      );

      // Align driver icon rotation with route direction
      if (points.length >= 2 && currentLatLng != null) {
        driverBearing.value = _bearingFromRoute(currentLatLng!, points);
        _updateCurrentMarker(currentLatLng!);
        _fitCameraToRoute();
      }
    } catch (e) {
      debugPrint('Directions API error: $e');
    }
  }

  int _parseDurationToMinutes(String duration) {
    if (duration.isEmpty) return 0;
    final hourReg = RegExp(r'(\d+)\s*hour');
    final minReg = RegExp(r'(\d+)\s*min');
    int hours =
        int.tryParse(hourReg.firstMatch(duration)?.group(1) ?? '0') ?? 0;
    int mins = int.tryParse(minReg.firstMatch(duration)?.group(1) ?? '0') ?? 0;
    return hours * 60 + mins;
  }

  void _fitCameraToRoute() {
    if (polylines.isEmpty || mapController == null) return;
    final points = polylines.first.points;
    if (points.isEmpty) return;

    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      debugPrint('_fitCameraToRoute error: $e');
      if (currentLatLng != null) {
        try {
          mapController!.animateCamera(CameraUpdate.newLatLng(currentLatLng!));
        } catch (e2) {
          debugPrint('_fitCameraToRoute fallback error: $e2');
        }
      }
    }
  }

  void _fitCameraToIncludeCurrent() {
    if (currentLatLng == null || mapController == null) return;
    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng!, 15),
      );
    } catch (e) {
      debugPrint('_fitCameraToIncludeCurrent error: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLatLng != null) {
      _updateRoute();
      _fitCameraToIncludeCurrent();
    }
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> _syncLocationToServer() async {
    if (currentLatLng == null) return;
    try {
      final idRaw = shipment['id'];
      int? orderId;
      if (idRaw is int) {
        orderId = idRaw;
      } else if (idRaw is String) {
        orderId = int.tryParse(idRaw);
      }

      if (orderId != null) {
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ 📍 SYNCING DRIVER LOCATION (every 10s)');
        debugPrint('║ Order ID: $orderId');
        debugPrint('║ Lat: ${currentLatLng!.latitude}');
        debugPrint('║ Lng: ${currentLatLng!.longitude}');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        
        await _repo.updateShipment(
          orderId: orderId,
          lat: currentLatLng!.latitude,
          lng: currentLatLng!.longitude,
        );
        debugPrint('✅ Location synced successfully');
      } else {
        debugPrint("Skipping location sync: Invalid orderId ($idRaw)");
      }
    } catch (e) {
      debugPrint("❌ Location sync error: $e");
    }
  }
}

class DriverOrderTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverOrderTrackingController());
    ever(ctrl.polylines, (_) => ctrl.update(['map']));
    ever(ctrl.markers, (_) => ctrl.update(['map']));

    return Scaffold(
      body: Stack(
        children: [
          GetBuilder<DriverOrderTrackingController>(
            id: 'map',
            builder: (ctrl) {
              // Get initial target - use destination based on stage
              final isToPickup = ctrl.stage.value == DeliveryStage.toPickup;
              final initialTarget = isToPickup ? ctrl.pickupLatLng : ctrl.dropoffLatLng;
              
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 15,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                markers: ctrl.markers,
                polylines: ctrl.polylines,
                onMapCreated: ctrl.onMapCreated,
                zoomControlsEnabled: false,
              );
            },
          ),
          // Loading indicator while fetching location
          Obx(() => ctrl.isLocationLoading.value
              ? Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Getting your location...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Positioned(
            left: 16,
            right: 16,
            bottom: 22,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _buildCard(ctrl),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(DriverOrderTrackingController ctrl) {
    final pickup = ctrl.shipment['pickup'] ?? {};
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            '${ctrl.etaMinutes.value} minutes to ${ctrl.stage.value == DeliveryStage.toPickup ? 'Pick up' : 'delivery'}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Immediate',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primarySwatch.shade100,
              child: Text(
                _initials((pickup['name'] as String?) ?? 'PV'),
                style: TextStyle(
                  color: AppColors.primarySwatch.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (pickup['name'] as String?) ?? 'Parikshit Verma',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Order id: ${ctrl.shipment['id'] ?? 'dc5a07-af3-4e7c-...'}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CircularIconButton(icon: IconlyBold.call, onTap: () {}),
                      SizedBox(width: 12),
                      CircularIconButton(icon: IconlyBold.chat, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ctrl.isActionButtonEnabled.value
                  ? ctrl.onActionButtonPressed
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                ctrl.actionButtonText.value,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
  }
}
