// lib/modules/screens/vehicle_details_screen.dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant/app_colors.dart';
import '../widgets/custom_text_field.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  // Text Editing Controllers
  final ownerNameCtrl = TextEditingController();
  final vehicleNumberCtrl = TextEditingController();
  final registeringAuthCtrl = TextEditingController();
  final vehicleTypeCtrl = TextEditingController();
  final fuelTypeCtrl = TextEditingController();
  final vehicleAgeCtrl = TextEditingController();
  final vehicleStatusCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  String? _vehicleImageUrl; // if backend gives HTTP URL

  @override
  void initState() {
    super.initState();
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      ownerNameCtrl.text = (args['ownerName'] ?? '') as String;
      vehicleNumberCtrl.text = (args['vehicleNumber'] ?? '') as String;
      registeringAuthCtrl.text = (args['registeringAuth'] ?? '') as String;
      vehicleTypeCtrl.text = (args['vehicleType'] ?? '') as String;
      fuelTypeCtrl.text = (args['fuelType'] ?? '') as String;
      vehicleAgeCtrl.text = (args['vehicleAge'] ?? '') as String;
      vehicleStatusCtrl.text = (args['vehicleStatus'] ?? '') as String;

      // image: either a local path (vehicleImagePath) or remote url (vehicleImageUrl)
      final localPath = args['vehicleImagePath'];
      final remoteUrl = args['vehicleImageUrl'];
      if (localPath != null && localPath is String && localPath.isNotEmpty) {
        _pickedImage = File(localPath);
      } else if (remoteUrl != null && remoteUrl is String && remoteUrl.isNotEmpty) {
        _vehicleImageUrl = remoteUrl;
      }
      setState(() {});
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file != null) {
      setState(() {
        _pickedImage = File(file.path);
        _vehicleImageUrl = null;
      });
    }
  }

  Future<void> _captureImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file != null) {
      setState(() {
        _pickedImage = File(file.path);
        _vehicleImageUrl = null;
      });
    }
  }

  void _showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Image",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  _captureImage();
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  _pickFromGallery();
                  Get.back();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ownerNameCtrl.dispose();
    vehicleNumberCtrl.dispose();
    registeringAuthCtrl.dispose();
    vehicleTypeCtrl.dispose();
    fuelTypeCtrl.dispose();
    vehicleAgeCtrl.dispose();
    vehicleStatusCtrl.dispose();
    super.dispose();
  }

  void _onDone() {
    // Collect values and return to previous screen
    final result = {
      'ownerName': ownerNameCtrl.text.trim(),
      'vehicleNumber': vehicleNumberCtrl.text.trim(),
      'registeringAuth': registeringAuthCtrl.text.trim(),
      'vehicleType': vehicleTypeCtrl.text.trim(),
      'fuelType': fuelTypeCtrl.text.trim(),
      'vehicleAge': vehicleAgeCtrl.text.trim(),
      'vehicleStatus': vehicleStatusCtrl.text.trim(),
      // send image path if available
      if (_pickedImage != null) 'vehicleImagePath': _pickedImage!.path,
      if (_vehicleImageUrl != null) 'vehicleImageUrl': _vehicleImageUrl,
    };

    Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        leading: IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.back,color: Colors.white,)),
        title: Text(
          "Vehicle Details",
          style: TextStyle(
              fontSize: 18, color: AppColors.textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGE BOX ----------------
            Center(
              child: InkWell(
                onTap: _showImagePickerBottomSheet,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                    image: _pickedImage != null
                        ? DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_pickedImage!),
                    )
                        : (_vehicleImageUrl != null
                        ? DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(_vehicleImageUrl!),
                    )
                        : null),
                  ),
                  child: (_pickedImage == null && _vehicleImageUrl == null)
                      ? const Center(
                    child: Icon(Icons.camera_alt, size: 45, color: Colors.grey),
                  )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Vehicle Picture",
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),

            // ---------------- TEXT FIELDS ----------------
            CustomTextField(
              controller: ownerNameCtrl,
              label: "Owner Name",
              hint: "Enter owner name",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: vehicleNumberCtrl,
              label: "Vehicle Number",
              hint: "RJ14 1920",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: registeringAuthCtrl,
              label: "Registering authority",
              hint: "Jaipur city",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: vehicleTypeCtrl,
              label: "Vehicle Type",
              hint: "Bike",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: fuelTypeCtrl,
              label: "Fuel Type",
              hint: "Petrol",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: vehicleAgeCtrl,
              label: "Vehicle Age",
              hint: "5 years 2 months",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: vehicleStatusCtrl,
              label: "Vehicle Status",
              hint: "Active / Inactive",
              labelColor: AppColors.textPrimary,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: AppColors.primary, width: 3.0),
              ),
            ),
            const SizedBox(height: 24),

            // ---------------- DONE BUTTON ----------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _onDone,
                child: const Text(
                  "Done",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
