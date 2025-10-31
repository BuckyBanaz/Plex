import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/modules/controllers/booking/booking_controller.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';
import '../../map/location_picker_screen.dart';
import 'components/address_chip.dart';
import 'components/location_card.dart';

class DropOffDetailsScreen extends StatelessWidget {
  const DropOffDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.put(BookingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(CupertinoIcons.back),
        ),
        title: Text(
          "enter_dropoff_details".tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Obx(() => LocationCard(
            onTap: () async {
              final result =
              await Get.to(() => const LocationPickerScreen(isPickup: false));
              if (result != null) {
                controller.dLocality.value = result['address'];
                controller.dpincodeController.text = result['pincode'];
                controller.dLat.value = result['lat'];
                controller.dLng.value = result['lng'];
              }
            },
            location: controller.dLocality.value.isEmpty
                ? "tap_select_location".tr
                : controller.dLocality.value,
            fullLocation: controller.dLocality.value,
          )),
          const SizedBox(height: 24.0),
          SimpleTextField(
            controller: controller.dnameController,
            labelText: "full_name".tr,

          ),
          const SizedBox(height: 16.0),
          SimpleTextField(
            controller: controller.dmobileController,
            labelText: "mobile_number".tr,
            keyboardType: TextInputType.phone,

          ),
          const SizedBox(height: 16.0),
          SimpleTextField(
            controller: controller.dlankmarkController,
            labelText: "house_building".tr,

          ),
          const SizedBox(height: 16.0),
          SimpleTextField(
            controller: controller.dpincodeController,
            labelText: "pincode".tr,
            keyboardType: TextInputType.number,

          ),
          const SizedBox(height: 24.0),
          Text(
            "save_address_as".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

          ),
          const SizedBox(height: 12.0),
          Obx(
                () => Row(
              children: [
                AddressChip(
                  label: "home".tr,
                  isSelected: controller.dselectedAddressType.value == "Home",
                  onTap: () => controller.dselectAddressType("Home"),
                ),
                const SizedBox(width: 12.0),
                AddressChip(
                  label: "shop".tr,
                  isSelected: controller.dselectedAddressType.value == "Shop",
                  onTap: () => controller.dselectAddressType("Shop"),
                ),
                const SizedBox(width: 12.0),
                AddressChip(
                  label: "other".tr,
                  isSelected: controller.dselectedAddressType.value == "Other",
                  onTap: () => controller.dselectAddressType("Other"),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          final bool isValid = controller.isDropOffFormValid.value;
          final Color buttonColor = isValid ? AppColors.primary : Colors.grey[300]!;
          final Color textColor = isValid ? Colors.white : Colors.black54;

          return ConfirmButton(
            bg: buttonColor,
            label: Center(
              child: Text(
                "confirm".tr,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: isValid ? controller.confirmDropOffDetails : null,
          );
        }),
      ),
    );
  }
}
