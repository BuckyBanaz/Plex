import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/driver/order/driver_order_tracking_screen.dart';

class PickupConfirmedScreen extends StatefulWidget {
  final String orderNumber;
  final Map<String, dynamic>? shipment;
  
  const PickupConfirmedScreen({
    super.key, 
    this.orderNumber = "#A23456",
    this.shipment,
  });

  @override
  State<PickupConfirmedScreen> createState() => _PickupConfirmedScreenState();
}

class _PickupConfirmedScreenState extends State<PickupConfirmedScreen> {
  Position? _currentPosition;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fetch location immediately when screen opens
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() => _currentPosition = position);
        debugPrint('📍 Pre-fetched location: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      debugPrint('⚠️ Could not pre-fetch location: $e');
      // Try last known
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null && mounted) {
          setState(() => _currentPosition = lastPos);
        }
      } catch (_) {}
    }
  }

  String get orderNumber => widget.orderNumber;
  Map<String, dynamic>? get shipment => widget.shipment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),

            // Success circle
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 64, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Title
            Text(
              "Pickup Confirmed",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                "The package has been successfully picked up. Head to the delivery location now.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order number
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Order: $orderNumber",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // Continue to Delivery button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isNavigating ? null : () async {
                    if (shipment != null) {
                      setState(() => _isNavigating = true);
                      
                      // Update shipment status to picked_up before passing
                      final updatedShipment = Map<String, dynamic>.from(shipment!);
                      updatedShipment['status'] = 'picked_up';
                      
                      // If we don't have location yet, quickly try to get it
                      if (_currentPosition == null) {
                        try {
                          _currentPosition = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                            timeLimit: const Duration(seconds: 2),
                          );
                        } catch (_) {
                          // Use last known as fallback
                          _currentPosition = await Geolocator.getLastKnownPosition();
                        }
                      }
                      
                      debugPrint('╔══════════════════════════════════════════════════════════════');
                      debugPrint('║ 📦 PICKUP CONFIRMED - INSTANT NAVIGATION');
                      debugPrint('║ Pre-fetched Location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
                      debugPrint('║ Dropoff: ${updatedShipment['dropoff']}');
                      debugPrint('╚══════════════════════════════════════════════════════════════');
                      
                      // Delete old controller to ensure fresh state
                      Get.delete<DriverOrderTrackingController>(force: true);
                      
                      // Go back to tracking screen with BOTH shipment AND current location
                      Get.offAll(
                        () => DriverOrderTrackingScreen(),
                        arguments: {
                          'shipment': updatedShipment,
                          'currentLat': _currentPosition?.latitude,
                          'currentLng': _currentPosition?.longitude,
                          'heading': _currentPosition?.heading ?? 0.0,
                        },
                      );
                    } else {
                      debugPrint('❌ PICKUP CONFIRMED - No shipment data!');
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Continue to Delivery",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
