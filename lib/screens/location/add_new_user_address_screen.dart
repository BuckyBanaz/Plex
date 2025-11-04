import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';
import '../../modules/controllers/location/add_new_user_address_controller.dart';

class AddNewUserAddressScreen extends GetView<AddNewAddressController> {
  const AddNewUserAddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(AddNewAddressController());

    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Select delivery location',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ) ,
      body: Stack(
        children: [
          _buildMap(),
          _buildPin(),
          _buildDraggableSheet(context),
        ],
      ),
    );
  }


  Widget _buildMap() {
    return Obx(
      () => GoogleMap(
        initialCameraPosition: CameraPosition(
          target: controller.initialLocation.value,
          zoom: 16.0,
        ),
        onMapCreated: controller.onMapCreated,
        onCameraMove: controller.onCameraMove,
        onCameraIdle: controller.onCameraIdle,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }

  Widget _buildPin() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 40.0,
        ), // Pin ki tip ko center karne ke liye
        child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
      ),
    );
  }

  Widget _buildDraggableSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45, // Sheet initially kitni open ho
      minChildSize: 0.45, // Minimum kitni open rahegi
      maxChildSize: 0.85, // Max kitni open ho sakti hai
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: _buildSheetContent(scrollController),
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        // Center drag handle
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Selected Location
        Obx(() {
          return ListTile(
            leading: Icon(IconlyBold.location, color: AppColors.primary),
            title: Text(
              controller.isLoadingAddress.value
                  ? 'Loading...'
                  : controller.selectedAddress.value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: controller.isLoadingAddress.value
                ? null
                : Text(controller.selectedLocality.value),
          );
        }),
        const Divider(height: 24),


        CustomTextField(
          controller: controller.landmarkController,
          label: 'Address details*',
          labelColor: AppColors.textPrimary,
          hint: 'E.g. Floor, House no., Landmark',
          hintColor: AppColors.textGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),

        const SizedBox(height: 16),

        // Save Address As
        const Text(
          'Save address as',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildAddressTypeToggle(),
        const SizedBox(height: 16),
        Obx(
          () => CustomButton(
            onTap: () {
              controller.isSaving.value ? null : controller.saveAddress();
            },
            widget: Center(
              child: controller.isSaving.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save address',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeToggle() {
    return Obx(() {
      final selectedType = controller.selectedAddressType.value;
      return Row(
        children: [
          _buildTypeButton('Home', IconlyBold.home, selectedType == 'Home'),
          const SizedBox(width: 10),
          _buildTypeButton('Work', IconlyBold.work, selectedType == 'Work'),
          const SizedBox(width: 10),
          _buildTypeButton(
            'Other',
            IconlyBold.location,
            selectedType == 'Other',
          ),
        ],
      );
    });
  }

  Widget _buildTypeButton(String label, IconData icon, bool isSelected) {
    return OutlinedButton.icon(
      onPressed: () => controller.onAddressTypeSelected(label),
      icon: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[700]),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? AppColors.primary! : Colors.grey[400]!,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

}
