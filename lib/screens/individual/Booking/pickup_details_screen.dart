import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';
import '../../../modules/controllers/booking/booking_controller.dart';
import '../../map/location_picker_screen.dart';
import 'components/address_chip.dart';
import 'components/location_card.dart';

class PickupDetailsScreen extends StatelessWidget {
  const PickupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.put(BookingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrow_left_2),
        ),
        title: const Text(
          "Enter pickup details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // LocationCard(
          Obx(() => LocationCard(
            onTap: () async {
              final result = await Get.to(() => const LocationPickerScreen(isPickup: true));
              if (result != null) {
                controller.pLocality.value = result['address'];
                controller.pPincodeController.text = result['pincode'];
                controller.pLat.value = result['lat'];
                controller.pLng.value = result['lng'];
              }
            },
            location: controller.pLocality.value.isEmpty
                ? "Tap to select location"
                : controller.pLocality.value,
            fullLocation: controller.pLocality.value,
          )),
          const SizedBox(height: 24.0),

          SimpleTextField(
            controller: controller.pNameController,
            labelText: "Full Name",
          ),
          const SizedBox(height: 16.0),
          SimpleTextField(
            controller: controller.pMobileController,
            labelText: "Mobile Number",
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16.0),
          SimpleTextField(
            controller: controller.pLandMarkController,
            labelText: "House No/Flat No/ Building Name",
          ),
          const SizedBox(height: 16.0),
          SimpleTextField(
            controller: controller.pPincodeController,
            labelText: "Pincode",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24.0),

          const Text(
            "Save address as:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
          Obx(
            () => Row(
              children: [
                AddressChip(
                  label: "Home",
                  isSelected: controller.pselectedAddressType.value == "Home",
                  onTap: () => controller.pselectAddressType("Home"),
                ),
                const SizedBox(width: 12.0),
                AddressChip(
                  label: "Shop",
                  isSelected: controller.pselectedAddressType.value == "Shop",
                  onTap: () => controller.pselectAddressType("Shop"),
                ),
                const SizedBox(width: 12.0),
                AddressChip(
                  label: "Other",
                  isSelected: controller.pselectedAddressType.value == "Other",
                  onTap: () => controller.pselectAddressType("Other"),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),

        child: Obx(() {

          final bool isValid = controller.isPickUpFormValid.value;

          final Color buttonColor = isValid ? AppColors.primary : Colors.grey[300]!;
          final Color textColor = isValid ? Colors.white : Colors.black54;

          return ConfirmButton(
            bg: buttonColor,
            label: Center(
              child: Text(
                "Confirm",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: isValid ? controller.confirmPickupDetails : null,
          );
        }),
      ),
    );
  }
}
