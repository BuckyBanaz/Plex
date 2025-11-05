import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/modules/controllers/location/user_address_controller.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_text_field.dart';

class AddNewUserAddressScreen extends StatefulWidget {
  const AddNewUserAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddNewUserAddressScreen> createState() => _AddNewUserAddressScreenState();
}

class _AddNewUserAddressScreenState extends State<AddNewUserAddressScreen> {
  late final UserAddressController controller;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // sheet size constants
  final double _minSize = 0.12; // nearly hidden but still draggable
  final double _initialSize = 0.45;
  final double _maxSize = 0.85;

  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserAddressController());
  }

  @override
  void dispose() {
    // optionally clean controller
    // Get.delete<UserAddressController>();
    super.dispose();
  }

  Future<void> _snapTo(double size) async {
    // Use DraggableScrollableActuator to animate; fallback to controller.animateTo
    try {
      await _sheetController.animateTo(size, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _collapseSheet() async {
    await _snapTo(_minSize);
  }

  Future<void> _expandSheet() async {
    await _snapTo(_initialSize);
  }

  Future<void> _toggleSheet() async {
    if (_isCollapsed) {
      await _expandSheet();
    } else {
      await _collapseSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select delivery location',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          _buildMap(controller),
          _buildPin(),
          _buildSearchBar(controller),
          _buildDraggableSheet(context, controller),
        ],
      ),
    );
  }

  Widget _buildMap(UserAddressController controller) {
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
        padding: EdgeInsets.only(bottom: 40.0),
        child: Icon(Icons.location_pin, color: Colors.red, size: 40.0),
      ),
    );
  }

  Widget _buildSearchBar(UserAddressController controller) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'search_location_hint'.tr,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Obx(() {
            if (controller.suggestions.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: ListView.builder(
                itemCount: controller.suggestions.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final suggestion = controller.suggestions[index];
                  return ListTile(
                    leading: Icon(IconlyBold.location, color: AppColors.primary),
                    title: Text(suggestion['description'] ?? suggestion['formatted'] ?? ""),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      controller.selectSuggestion(suggestion);
                      _collapseSheet(); // collapse for better map view
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet(BuildContext context, UserAddressController controller) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _initialSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true, // optional; enables snapping behavior on supported Flutter versions
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, spreadRadius: 1.0)],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                final current = notification.extent;
                final bool collapsed = current <= (_minSize + 0.01);
                if (collapsed != _isCollapsed) {
                  setState(() => _isCollapsed = collapsed);
                }
                return false;
              },
              child: _buildSheetContent(scrollController, controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(ScrollController scrollController, UserAddressController controller) {
    return Column(
      children: [
        // Top row: small tappable handle and collapse/expand icon
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SMALL handle - doesn't block vertical drag (InkWell won't steal vertical drag)
              InkWell(
                onTap: _toggleSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                ),
              ),
              // const SizedBox(width: 12),
              // // collapse/expand button - separate and only handles taps
              // IconButton(
              //   onPressed: _toggleSheet,
              //   icon: Icon(_isCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              // ),
            ],
          ),
        ),

        // The inner scrollable list - pass the controller provided by DraggableScrollableSheet
        Expanded(
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(), // smooth scrolling
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 4),

              Obx(() {
                return ListTile(
                  leading: Icon(IconlyBold.location, color: AppColors.primary),
                  title: Text(
                    controller.isLoadingAddress.value ? 'Loading...' : controller.selectedAddress.value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: controller.isLoadingAddress.value ? null : Text(controller.selectedLocality.value),
                );
              }),

              const Divider(height: 24),

              CustomTextField(
                controller: controller.landmarkController,
                label: 'Address details*',
                labelColor: AppColors.textPrimary,
                hint: 'E.g. Floor, House no., Landmark',
                hintColor: AppColors.textGrey,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 1)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey, width: 1)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),

              const SizedBox(height: 16),
              const Text('Save address as', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildAddressTypeToggle(controller),
              const SizedBox(height: 16),

              Obx(
                    () => CustomButton(
                  onTap: () {
                    if (!controller.isSaving.value) controller.saveAddress();
                  },
                  widget: Center(
                    child: controller.isSaving.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save address', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Quick action to hide sheet for better map picking
              // TextButton.icon(
              //   onPressed: _collapseSheet,
              //   icon: const Icon(Icons.expand_more),
              //   label: const Text('Hide sheet to pick location'),
              // ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeToggle(UserAddressController controller) {
    return Obx(() {
      final selectedType = controller.selectedAddressType.value;
      return Row(
        children: [
          _buildTypeButton('Home', IconlyBold.home, selectedType == 'Home', controller),
          const SizedBox(width: 10),
          _buildTypeButton('Work', IconlyBold.work, selectedType == 'Work', controller),
          const SizedBox(width: 10),
          _buildTypeButton('Other', IconlyBold.location, selectedType == 'Other', controller),
        ],
      );
    });
  }

  Widget _buildTypeButton(String label, IconData icon, bool isSelected, UserAddressController controller) {
    return OutlinedButton.icon(
      onPressed: () => controller.onAddressTypeSelected(label),
      icon: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[700]),
      label: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.grey[700])),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? AppColors.primary! : Colors.grey[400]!, width: isSelected ? 2 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
