// lib/screens/auth/vehicle_details_screen.dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../../constant/app_colors.dart';
import '../../services/domain/repository/repository_imports.dart';
import '../../services/domain/service/app/app_service_imports.dart';
import '../widgets/custom_text_field.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';

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
  final fuelTypeCtrl = TextEditingController();
  final vehicleAgeCtrl = TextEditingController();

  // Dropdown values
  String? selectedVehicleType;
  final vehicleTypes = ['Bike', 'Car', 'Van', 'Truck'];

  String? selectedFuelType;
  final fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric'];

  final DatabaseService databaseService = Get.find<DatabaseService>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  String? _vehicleImageUrl;

  bool _isLoading = false;

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
      
      // Set dropdown values if provided
      final vType = args['vehicleType'] as String?;
      if (vType != null && vType.isNotEmpty && vehicleTypes.contains(vType)) {
        selectedVehicleType = vType;
      }
      
      final fType = args['fuelType'] as String?;
      if (fType != null && fType.isNotEmpty && fuelTypes.contains(fType)) {
        selectedFuelType = fType;
      }
      
      vehicleAgeCtrl.text = (args['vehicleAge'] ?? '') as String;

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
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text("Camera"),
                onTap: () {
                  _captureImage();
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: AppColors.primary),
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
    fuelTypeCtrl.dispose();
    vehicleAgeCtrl.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (ownerNameCtrl.text.trim().isEmpty) {
      CustomSnackbar.error('Please enter owner name', title: 'Error');
      return false;
    }
    if (selectedVehicleType == null) {
      CustomSnackbar.error('Please select vehicle type', title: 'Error');
      return false;
    }
    if (selectedFuelType == null) {
      CustomSnackbar.error('Please select fuel type', title: 'Error');
      return false;
    }
    return true;
  }

  Future<void> _onSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Parse vehicle age
      int vehicleAge = 0;
      final ageText = vehicleAgeCtrl.text.trim();
      if (ageText.isNotEmpty) {
        // Try to extract number from text like "5 years" or just "5"
        final match = RegExp(r'\d+').firstMatch(ageText);
        if (match != null) {
          vehicleAge = int.tryParse(match.group(0) ?? '0') ?? 0;
        }
      }

      final response = await _authRepo.submitVehicleDetails(
        ownerName: ownerNameCtrl.text.trim(),
        registeringAuthority: registeringAuthCtrl.text.trim(),
        vehicleType: selectedVehicleType!,
        fuelType: selectedFuelType!,
        vehicleAge: vehicleAge,
        vehicleImage: _pickedImage,
      );

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        databaseService.putKycDone(true);
        
        CustomSnackbar.success(
          response['message'] ?? 'Vehicle details submitted successfully',
          title: 'Success',
        );

        // Navigate to approval screen
        Get.offAllNamed(AppRoutes.approvel);
      } else {
        CustomSnackbar.error(
          response['message'] ?? 'Failed to submit vehicle details',
          title: 'Error',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Vehicle details submission error: $e');
      CustomSnackbar.error(
        'Failed to submit vehicle details. Please try again.',
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "Vehicle Details",
          style: TextStyle(fontSize: 18, color: AppColors.textColor),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        border: Border.all(color: Colors.grey.shade400),
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
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 45, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  "Tap to add vehicle photo",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Vehicle Picture (Optional)",
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),

                // ---------------- OWNER NAME ----------------
                CustomTextField(
                  controller: ownerNameCtrl,
                  label: "Owner Name *",
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

                // ---------------- REGISTERING AUTHORITY ----------------
                CustomTextField(
                  controller: registeringAuthCtrl,
                  label: "Registering Authority",
                  hint: "e.g. Jaipur RTO",
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

                // ---------------- VEHICLE TYPE DROPDOWN ----------------
                const Text(
                  "Vehicle Type *",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: InputDecoration(
                    hintText: "Select vehicle type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: vehicleTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedVehicleType = value);
                  },
                ),
                const SizedBox(height: 14),

                // ---------------- FUEL TYPE DROPDOWN ----------------
                const Text(
                  "Fuel Type *",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedFuelType,
                  decoration: InputDecoration(
                    hintText: "Select fuel type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: fuelTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedFuelType = value);
                  },
                ),
                const SizedBox(height: 14),

                // ---------------- VEHICLE AGE ----------------
                CustomTextField(
                  controller: vehicleAgeCtrl,
                  label: "Vehicle Age",
                  hint: "e.g. 5 years",
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

                // ---------------- SUBMIT BUTTON ----------------
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
                    onPressed: _isLoading ? null : _onSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Submit",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
