import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../models/user_models.dart';
import '../../modules/controllers/location/user_address_controller.dart';


class UserAddressScreen extends GetView<UserAddressController> {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UserAddressController());
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor:  AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: Text('select_location'.tr),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primaryColor),
                hintText: 'search_area'.tr,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                // side: BorderSide(color: AppColors.primarySwatch),

              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Obx(
                        () => ListTile(
                      leading: Icon(Icons.my_location, color: primaryColor),
                      title: Text(
                        'use_current_location'.tr,
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        controller.currentLocationAddress.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: controller.isFetchingLocation.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.chevron_right),
                      onTap: controller.isFetchingLocation.value
                          ? null
                          : controller.fetchCurrentLocation,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.add, color: primaryColor),
                    title: Text(
                      'add_address'.tr,
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: controller.goToAddAddressScreen,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'saved_addresses'.tr,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // --- Saved Addresses List ---
          Expanded(
            child: Obx(
                  () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = controller.savedAddresses[index];
                  return _buildAddressCard(context, address, controller);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAddressCard(
      BuildContext context, AddressModel address, UserAddressController controller) {
    IconData iconData;
    String addressType = address.addressAs ?? 'other'.tr;
    if (addressType.toLowerCase() == 'home'.tr.toLowerCase()) {
      iconData = IconlyBold.home;
    } else if (addressType.toLowerCase() == 'work'.tr.toLowerCase()) {
      iconData = IconlyBold.work;
    } else {
      iconData = IconlyBold.location;
    }

    return Card(
       elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.selectSavedAddress(address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(iconData, color:AppColors.primary),
                  const SizedBox(height: 4),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addressType,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.address ?? '',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    // const SizedBox(height: 8),
                    // Text(
                    //   '${'phone_number'.tr}: ${address.phoneNumber ?? ''}',
                    //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    // ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.more_horiz,
                              color: Colors.grey[700]),
                          onPressed: () {
                            Get.bottomSheet(
                              Wrap(
                                children: [
                                  ListTile(
                                    leading:  Icon(IconlyBold.edit),
                                    title: Text('Edit'.tr), // 'Edit' ka translation add karein
                                    onTap: () {
                                      Get.back();
                                      controller.editAddress(address);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    title: Text('Delete'.tr, // 'Delete' ka translation add karein
                                        style:
                                        const TextStyle(color: Colors.red)),
                                    onTap: () {
                                      Get.back();
                                      controller.deleteAddress(address);
                                    },
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.white,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(CupertinoIcons.arrow_turn_up_right,
                              color: Theme.of(context).primaryColor),
                          onPressed: () {
                            // Google maps par navigation ka logic
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
