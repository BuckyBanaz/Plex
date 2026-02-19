import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as gt;
import 'package:plex_user/constant/api_endpoint.dart';
import 'package:plex_user/services/domain/service/api/api_import.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';

/// Service to handle driver location updates every 2 minutes
/// Only active when driver is on the dashboard
class DriverLocationService extends gt.GetxController {
  Timer? _locationTimer;
  final Dio _dio = gt.Get.find<ApiService>().dio;
  final DatabaseService _db = gt.Get.find<DatabaseService>();
  
  // Location update interval (2 minutes)
  static const Duration _updateInterval = Duration(minutes: 2);
  
  // Track if service is running
  final _isRunning = false.obs;
  bool get isRunning => _isRunning.value;

  /// Start periodic location updates
  void startLocationUpdates() {
    if (_isRunning.value) {
      debugPrint('[DriverLocation] Already running, skipping start');
      return;
    }
    
    // Check if user is a driver
    if (_db.userType != 'driver') {
      debugPrint('[DriverLocation] Not a driver, skipping location service');
      return;
    }
    
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 📍 DRIVER LOCATION SERVICE STARTED');
    debugPrint('║ Update interval: ${_updateInterval.inMinutes} minutes');
    debugPrint('╚══════════════════════════════════════════════════════════════');
    
    _isRunning.value = true;
    
    // Send location immediately on start
    _sendCurrentLocation();
    
    // Then schedule periodic updates
    _locationTimer = Timer.periodic(_updateInterval, (_) {
      _sendCurrentLocation();
    });
  }

  /// Stop periodic location updates
  void stopLocationUpdates() {
    if (!_isRunning.value) {
      debugPrint('[DriverLocation] Not running, skipping stop');
      return;
    }
    
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🛑 DRIVER LOCATION SERVICE STOPPED');
    debugPrint('╚══════════════════════════════════════════════════════════════');
    
    _locationTimer?.cancel();
    _locationTimer = null;
    _isRunning.value = false;
  }

  /// Get current position and send to server
  Future<void> _sendCurrentLocation() async {
    try {
      debugPrint('[DriverLocation] Getting current position...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[DriverLocation] Location services disabled');
        return;
      }
      
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        debugPrint('[DriverLocation] Location permission denied');
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      debugPrint('[DriverLocation] Got position: ${position.latitude}, ${position.longitude}');
      
      // Send to server
      await _updateLocationOnServer(position);
      
    } catch (e) {
      debugPrint('[DriverLocation] Error getting location: $e');
    }
  }

  /// Send location to backend API
  Future<void> _updateLocationOnServer(Position position) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoint.baseUrl}${ApiEndpoint.driverLocation}',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'heading': position.heading,
          'speed': position.speed,
        },
      );
      
      if (response.statusCode == 200) {
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ ✅ LOCATION UPDATED SUCCESSFULLY');
        debugPrint('║ Lat: ${position.latitude}');
        debugPrint('║ Lng: ${position.longitude}');
        debugPrint('║ Accuracy: ${position.accuracy}m');
        debugPrint('║ Speed: ${position.speed}m/s');
        debugPrint('║ Time: ${DateTime.now()}');
        debugPrint('╚══════════════════════════════════════════════════════════════');
      } else {
        debugPrint('[DriverLocation] Failed to update: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[DriverLocation] API Error: $e');
    }
  }

  /// Manual trigger for location update
  Future<void> forceUpdateLocation() async {
    debugPrint('[DriverLocation] Force update triggered');
    await _sendCurrentLocation();
  }

  @override
  void onClose() {
    stopLocationUpdates();
    super.onClose();
  }
}
