import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../modules/controllers/booking/driver_tracking_controller.dart';
import '../../../modules/controllers/booking/search_driver_controller.dart';
import '../../../modules/controllers/location/location_permission_controller.dart';
import '../../widgets/lottie_helpers.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'driver_tracking_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  const SearchingDriverScreen({Key? key}) : super(key: key);

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> {
  late final SearchDriverController searchCtrl;
  late final DriverTrackingController trackCtrl;
  late final LocationController locCtrl;
  GoogleMapController? mapController;
  Marker? userMarker;
  Marker? centerMarker;

  @override
  void initState() {
    super.initState();
    searchCtrl = Get.put(SearchDriverController());
    trackCtrl = Get.put(DriverTrackingController());
    locCtrl = Get.find<LocationController>();

    if (locCtrl.currentPosition.value == null) {
      locCtrl.loadCurrentAddress();
    }

    ever(searchCtrl.found, (bool f) {
      if (f == true && searchCtrl.foundDriver.value != null) {
        final d = searchCtrl.foundDriver.value!;
        final userLoc = locCtrl.currentPosition.value ?? LatLng(29.0333067, 75.939065);
        trackCtrl.startTracking(d, userLoc);
        Get.to(() => DriverTrackingScreen(driverId: d.id));
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = locCtrl.currentPosition.value ?? LatLng(29.0350, 75.9400);
    final cam = CameraPosition(target: initial, zoom: 14);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          Stack(
            children: [
              GoogleMap(
                initialCameraPosition: cam,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (c) => mapController = c,
                // markers: {
                //   if (locCtrl.currentPosition.value != null)
                //     Marker(
                //       markerId: MarkerId('user'),
                //       position: locCtrl.currentPosition.value!,
                //       // ✅ Green pin for user
                //       icon: BitmapDescriptor.defaultMarkerWithHue(
                //         BitmapDescriptor.hueGreen,
                //       ),
                //     ),
                // },
              ),

              // ✅ Show the Lottie animation only when searching
              if (searchCtrl.isSearching.value)
                const Center(
                  child: Stack(
                    children: [
                      SearchingLottie(
                        speed: 3,
                        size: 150,
                      ),
                    ],
                  ),
                ),
            ],
          ),


        ],
      ),
      bottomSheet: _buildBottomSheet(context),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Obx(() {
      final s = searchCtrl;
      return Container(
        width: double.infinity, // <-- ensure finite width
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // LEFT: texts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wait.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Finding your driver",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),

                // RIGHT: Trip Details button - wrap to give finite size
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Trip details',
                        'Show trip details (not implemented)',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size(80, 36), // give a minimum finite size
                    ),
                    child: Text("Trip Details"),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            LinearProgressIndicator(
              value: null,
              minHeight: 4,
              color: AppColors.primary,

              borderRadius: BorderRadius.circular(24),
              backgroundColor: AppColors.textGrey,
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Searching...",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                // ETA text should update reactively; wrap in Obx if needed
                Text(
                  "${s.etaSeconds.value}s",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusChip(Icons.search, "Scanning drivers"),
                _statusChip(Icons.directions_car, "Matching vehicle"),
                _statusChip(Icons.timer, "Estimating ETA"),
              ],
            ),

            SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  searchCtrl.cancelSearch();
                  Get.back();
                },
                child: Text("Cancel", style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statusChip(IconData ic, String title) {
    return Row(
      children: [
        Icon(ic, size: 18, color: Colors.orange),
        SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}
