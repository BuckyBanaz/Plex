// DetailLocationScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../modules/controllers/booking/booking_controller.dart';

// <-- FIX: StatelessWidget ko StatefulWidget banayein
class DetailLocationScreen extends StatefulWidget {
  DetailLocationScreen({super.key});

  @override
  State<DetailLocationScreen> createState() => _DetailLocationScreenState();
}

class _DetailLocationScreenState extends State<DetailLocationScreen> {
  final BookingController controller = Get.find<BookingController>();

  // <-- FIX: mapController ko state mein manage karein
  GoogleMapController? _googleMapController;

  @override
  void dispose() {
    // <-- FIX: Jab screen destroy ho, toh controller ko null set kar dein
    // Yeh crash ko rokega
    controller.mapController = null;

    // GoogleMapController ko bhi dispose karein agar woh initialized hai
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Location'),

      ),
      body: Obx(
            () {
          if (controller.pLat.value == 0.0 || controller.dLat.value == 0.0) {
            return const Center(
              child: Text("Select Pickup and Drop-off locations first"),
            );
          }

          Set<Marker> markers = {
            Marker(
              markerId: const MarkerId('pickup'),
              position: LatLng(controller.pLat.value, controller.pLng.value),
              infoWindow: const InfoWindow(title: 'Pickup'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
            ),
            Marker(
              markerId: const MarkerId('dropoff'),
              position: LatLng(controller.dLat.value, controller.dLng.value),
              infoWindow: const InfoWindow(title: 'Drop-off'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          };

          Set<Polyline> polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: controller.routePoints,
              color: Colors.orange,
              width: 5,
            ),
          };

          CameraPosition initialCamera = CameraPosition(
            target: LatLng(
              (controller.pLat.value + controller.dLat.value) / 2,
              (controller.pLng.value + controller.dLng.value) / 2,
            ),
            zoom: 10,
          );

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: initialCamera,
                markers: markers,
                polylines: polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController c) {
                  // <-- FIX: Dono controllers ko set karein
                  _googleMapController = c;
                  controller.mapController = c;
                  controller.fetchRoute();
                },
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
              ),
              // Positioned(
              //   bottom: 20,
              //   left: 16,
              //   right: 16,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Seedha next() call karein
              //       controller.next();
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.orange,
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8)),
              //     ),
              //     child: const Text(
              //       'Confirm',
              //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}