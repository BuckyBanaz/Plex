// file: lib/screens/individual/Booking/shipment_tracking_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconly/iconly.dart';

import '../../../constant/app_colors.dart';
import '../../../models/driver_order_model.dart';
import '../../../modules/controllers/booking/shipment_tracking_controller.dart';

class ShipmentTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const ShipmentTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<ShipmentTrackingScreen> createState() => _ShipmentTrackingScreenState();
}

class _ShipmentTrackingScreenState extends State<ShipmentTrackingScreen> {
  late final ShipmentTrackingController ctrl;
  GoogleMapController? _mapController;
  CameraPosition? _initialCamera;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(ShipmentTrackingController());
    ctrl.startTracking(widget.order);

    final pickup = widget.order.pickup;
    if (pickup.latitude != null && pickup.longitude != null) {
      _initialCamera = CameraPosition(target: LatLng(pickup.latitude!, pickup.longitude!), zoom: 13.5);
    }

    ever<LatLng?>(ctrl.driverLocation, (loc) {
      if (loc != null && _mapController != null) {
        try {
          _mapController!.animateCamera(CameraUpdate.newLatLng(loc));
        } catch (e) {
          debugPrint('animateCamera error: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.order.pickup;
    final fallbackLatLng = LatLng(pickup.latitude ?? 0.0, pickup.longitude ?? 0.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final Set<Marker> markers = ctrl.markers.value;
              final Set<Polyline> polylines = ctrl.polylines.value;

              return GoogleMap(
                initialCameraPosition: _initialCamera ?? CameraPosition(target: fallbackLatLng, zoom: 13.5),
                markers: markers,
                polylines: polylines,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController c) {
                  _mapController = c;
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _fitToBounds();
                  });
                },
              );
            }),
          ),
          Positioned(
            top: 56,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
              child: const Center(child: Text("Your partner is on the way!", style: TextStyle(color: Colors.white))),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Obx(() {
      final dloc = ctrl.driverLocation.value;
      final distance = ctrl.distanceMeters.value;
      final eta = ctrl.etaMinutes.value;

      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text("Your partner is on the way!", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 8),
                    Text("${(distance / 1000).toStringAsFixed(1)} km • $eta min", style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 12),
                if (dloc != null)
                  Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundColor: Colors.grey[200], child: Icon(Icons.person, color: Colors.grey[700])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ctrl.order.value?.driverDetails?['name'] ?? 'Driver', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(ctrl.order.value?.driverDetails?['vehicle'] ?? '-', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 6),
                            Row(children: const [Icon(Icons.star, size: 14, color: Colors.amber), SizedBox(width: 6), Text("4.1", style: TextStyle(color: Colors.grey))]),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(IconlyBold.call, color: Colors.green)),
                          IconButton(onPressed: () {}, icon: Icon(IconlyBold.chat, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: TextButton(onPressed: () => Get.back(), child: Text("Close", style: TextStyle(color: AppColors.primary)))),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _fitToBounds() async {
    if (_mapController == null) return;

    final currentOrder = ctrl.order.value ?? widget.order;
    final points = <LatLng>[];

    if (currentOrder.pickup.latitude != null && currentOrder.pickup.longitude != null) {
      points.add(LatLng(currentOrder.pickup.latitude!, currentOrder.pickup.longitude!));
    }
    if (currentOrder.dropoff.latitude != null && currentOrder.dropoff.longitude != null) {
      points.add(LatLng(currentOrder.dropoff.latitude!, currentOrder.dropoff.longitude!));
    }
    final d = ctrl.driverLocation.value;
    if (d != null) points.add(d);

    if (points.isEmpty) return;

    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
    try {
      await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (e) {
      debugPrint('fitToBounds error: $e');
    }
  }
}
