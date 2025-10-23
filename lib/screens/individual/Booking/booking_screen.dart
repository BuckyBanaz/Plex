import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/screens/individual/Booking/components/delivery_card.dart';
import 'package:plex_user/screens/individual/Booking/components/collect_time_selector.dart';

import '../../../modules/contollers/booking/booking_controller.dart';
import 'components/description_input.dart';
import 'components/photo_upload_section.dart';
import 'components/vehicle_type_selector.dart';
import 'components/weight_input.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.put(
      BookingController(),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const Text(
          "Booking Screen",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(IconlyLight.arrow_left_2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Select Location",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const DeliveryCard(),
          const SizedBox(height: 16.0),
          const Text(
            "Collect time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const CollectTimeSelector(),
          const SizedBox(height: 16.0),
          const Text(
            "Vehicle Type",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const VehicleTypeSelector(),
          const SizedBox(height: 16.0),
          const Text(
            "Weight",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const WeightInput(),
          const SizedBox(height: 16.0),
          const Text(
            "Description",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const DescriptionInput(),
          const SizedBox(height: 16.0),
          const Text(
            "Optional photo upload",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const PhotoUploadSection(),

          const SizedBox(height: 24.0),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: ()=>controller.next() ,


              child: Text("Next")),

          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
