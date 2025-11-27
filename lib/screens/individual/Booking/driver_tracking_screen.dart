// driver_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/models/driver_order_model.dart';

import '../../../modules/controllers/booking/driver_tracking_controller.dart';
import '../../../modules/controllers/location/location_permission_controller.dart';

class DriverTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const DriverTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  final DriverTrackingController trackCtrl = Get.put(
    DriverTrackingController(),
  );
  final LocationController locCtrl = Get.put(LocationController());
  GoogleMapController? mapController;
  BitmapDescriptor? driverIcon;
  @override
  void initState() {
    super.initState();

    // Optional: create custom marker icon async if you want
    // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48,48)), 'assets/driver.png')
    //   .then((b) => driverIcon = b);

    // Move camera when driver position updates — listen and animate camera smoothly
    trackCtrl.driver.listen((d) {
      if (d != null && mapController != null) {
        try {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(d.lat, d.lng), 14.0),
          );
        } catch (e) {
          // Map controller not ready yet, ignore silently
          debugPrint('animateCamera error: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    // trackCtrl.stopTracking(); // optionally stop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLoc = locCtrl.currentPosition.value ?? LatLng(29.0350, 75.9400);
    final cam = CameraPosition(target: userLoc, zoom: 13.5);

    return Scaffold(
      body: Stack(
        children: [
          // Full map with markers
          Positioned.fill(
            child: Obx(() {
              final d = trackCtrl.driver.value;
              final markers = <Marker>{};

              // user marker
              markers.add(
                Marker(
                  markerId: MarkerId('user'),
                  position: userLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              );

              // driver marker
              if (d != null) {
                markers.add(
                  Marker(
                    markerId: MarkerId('driver'),
                    position: LatLng(d.lat, d.lng),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange,
                    ),
                  ),
                );
              }

              // polyline from driver -> user (shrinks as driver moves)
              final polylines = <Polyline>{};
              if (d != null) {
                polylines.add(
                  Polyline(
                    color: AppColors.primary,
                    polylineId: PolylineId('route'),
                    points: [LatLng(d.lat, d.lng), userLoc],
                    width: 6,
                  ),
                );
              }

              return SizedBox.expand(
                child: GoogleMap(
                  key: const ValueKey('driver_tracking_map'),
                  initialCameraPosition: cam,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: markers,
                  polylines: polylines,
                  mapType: MapType.normal,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: true,
                  liteModeEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    if (mounted) {
                      mapController = controller;
                      debugPrint(
                        'DriverTrackingScreen: Map created successfully on iOS',
                      );
                      // Ensure map is ready before any operations
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted && mapController != null) {
                          try {
                            mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(cam),
                            );
                          } catch (e) {
                            debugPrint(
                              'Error animating camera on map created: $e',
                            );
                          }
                        }
                      });
                    }
                  },
                  onCameraMoveStarted: () {
                    debugPrint('DriverTrackingScreen: Camera move started');
                  },
                ),
              );
            }),
          ),

          // top banner
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Your Partner is on the way!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottom(context),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Obx(() {
      final d = trackCtrl.driver.value;
      final distance = trackCtrl.distanceMeters.value;
      final eta = trackCtrl.etaMinutes.value;

      // Bound the sheet height and ensure width is finite
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Your Partner is on his way!",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${(distance / 1000).toStringAsFixed(1)} km | ${eta} min",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    if (d != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.person, color: Colors.grey[700]),
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  d.vehicle,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "4.1",
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  IconlyBold.call,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  IconlyBold.chat,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
