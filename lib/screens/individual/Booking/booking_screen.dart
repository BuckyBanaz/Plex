import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/screens/individual/Booking/components/delivery_card.dart';
import 'package:plex_user/screens/individual/Booking/components/collect_time_selector.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';

import '../../../constant/app_colors.dart';
import '../../../modules/controllers/booking/booking_controller.dart';
import '../../../routes/appRoutes.dart';
import 'components/photo_upload_section.dart';
import 'components/vehicle_type_selector.dart';

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
    return Obx(

      () {

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title:  Text(
              "booking_screen_title".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon:  Icon(CupertinoIcons.back),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
               Text(
                "select_location".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              DeliveryCard(
                collectLabel: "collect_from".tr,
                collectAddress: controller.pAddress.value.isEmpty
                    ? "tap_to_select_location".tr
                    : controller.pAddress.value,
                onEditCollect: () {
                  Get.toNamed(AppRoutes.pickup);
                },
                deliveryLabel: "delivery_to".tr,
                deliveryName: controller.dnameController.text.isEmpty
                    ? "recipient_name".tr
                    : controller.dnameController.text,
                deliveryPhone: controller.dmobileController.text.isEmpty
                    ? "phone_number_placeholder".tr
                    : controller.dmobileController.text,
                deliveryAddress: controller.dAddress.value.isEmpty
                    ? "tap_to_select_location".tr
                    : controller.dAddress.value,
                onEditDelivery: () {
                  Get.toNamed(AppRoutes.dropOff);
                },
                durationText: "take_around".tr,
                onMapViewTap: () {
                  Get.toNamed(AppRoutes.locationDetails);
                  print("Map opened");
                },
              ),

              const SizedBox(height: 16.0),
               Text(
                "collect_time".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const CollectTimeSelector(),
              const SizedBox(height: 16.0),
               Text(
                "vehicle_type".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const VehicleTypeSelector(),
              const SizedBox(height: 16.0),
               Text(
                "weight".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const WeightInput(),
              const SizedBox(height: 16.0),
               Text(
                "description".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const DescriptionInput(),
              const SizedBox(height: 16.0),
               Text(
                "optional_photo_upload".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const PhotoUploadSection(),

              const SizedBox(height: 24.0),

              // CustomButton(onTap: ()=>controller.next(), label: "Next"),

              const SizedBox(height: 24.0),
            ],
          ),
          bottomNavigationBar:  CustomButton(onTap: ()=> controller.isLoading.value ?  null : controller.next(), widget: Center(
            child: controller.isLoading.value ? CircularProgressIndicator(strokeWidth: 3,color: AppColors.textColor,) :Text(
              "next".tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )) ,
        );
      },
    );
  }
}
