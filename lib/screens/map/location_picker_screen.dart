import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../modules/controllers/location/map_location_controller.dart';

class LocationPickerScreen extends StatelessWidget {
  final bool isPickup;
  const LocationPickerScreen({super.key, required this.isPickup});

  @override
  Widget build(BuildContext context) {
    final MapLocationController controller =
    Get.put(MapLocationController(), tag: isPickup ? "pickup" : "dropoff");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon:  Icon(CupertinoIcons.back),
        ),
        title: Text(isPickup ? "select_pickup_location".tr : "select_dropoff_location".tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return  Center(child: CircularProgressIndicator(strokeWidth: 3,color: AppColors.primary,));
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            /// --- Google Map ---
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentLatLng.value,
                zoom: 16,
              ),
              onMapCreated: (mapCtrl) => controller.mapController.complete(mapCtrl),
              onCameraMove: controller.onCameraMove,
              onCameraIdle: controller.onCameraIdle,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

            /// --- Center Pin Icon ---
             Icon(Icons.location_pin, size: 60, color: AppColors.secondary),

            /// --- Search Bar ---
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 8)
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration:  InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'search_location_hint'.tr,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  /// --- Suggestion List (below search bar) ---
                  Obx(() {
                    if (controller.suggestions.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8)
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: controller.suggestions.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final suggestion = controller.suggestions[index];
                          return ListTile(
                            leading:  Icon(IconlyBold.location, color: AppColors.primary),
                            title: Text(suggestion['description'] ?? ""),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              controller.selectSuggestion(suggestion);
                            },
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            /// --- Address Card ---
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Obx(
                    () => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.address.value,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(controller.fullAddress.value,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            /// --- Confirm Button ---
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Obx(() {
                final loading = controller.isConfirming.value;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    loading ? Colors.grey : AppColors.primary, // disable color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: loading
                      ? null // disable tap
                      : () {
                    Get.back(result: {
                      "address": controller.address.value,
                      "fullAddress": controller.fullAddress.value,
                      "pincode": controller.pincode.value,
                      "lat": controller.currentLatLng.value.latitude,
                      "lng": controller.currentLatLng.value.longitude,
                    });
                  },
                  child: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      :  Text(
                    "confirm_location".tr,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }),
            ),

          ],
        );
      }),
    );
  }
}
