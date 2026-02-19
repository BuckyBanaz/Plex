// lib/screens/auth/kyc/driver_kyc_screen.dart
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plex_user/common/Toast/toast.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import '../../../constant/app_colors.dart';
import '../../../services/domain/repository/repository_imports.dart';

class DriverKycFlow extends StatefulWidget {
  const DriverKycFlow({super.key});

  @override
  State<DriverKycFlow> createState() => _DriverKycFlowState();
}

class _DriverKycFlowState extends State<DriverKycFlow> {
  final DatabaseService db = Get.find<DatabaseService>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0; // 0 = ID Proof, 1 = Vehicle Info
  bool _isLoading = false;

  // Step 1: ID Proof Data
  String? _selectedIdType;
  final _idNumberController = TextEditingController();
  File? _idProofImage;
  File? _profilePhoto;

  // ID Types (International)
  final List<Map<String, String>> _idTypes = [
    {'value': 'drivers_license', 'label': 'Driver\'s License'},
    {'value': 'passport', 'label': 'Passport'},
    {'value': 'national_id', 'label': 'National ID Card'},
    {'value': 'residence_permit', 'label': 'Residence Permit'},
    {'value': 'government_id', 'label': 'Government ID'},
    {'value': 'other', 'label': 'Other Valid ID'},
  ];

  // Step 2: Vehicle Data
  String? _selectedVehicleType;
  final _licensePlateController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  String? _selectedFuelType;
  File? _vehicleImage;

  final List<String> _vehicleTypes = ['Bike', 'Car', 'Van', 'Truck', 'Auto', 'Other'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid', 'Other'];

  @override
  void dispose() {
    _idNumberController.dispose();
    _licensePlateController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (file != null) {
      setState(() {
        switch (type) {
          case 'id_proof':
            _idProofImage = File(file.path);
            break;
          case 'profile':
            _profilePhoto = File(file.path);
            break;
          case 'vehicle':
            _vehicleImage = File(file.path);
            break;
        }
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
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
              const Text(
                "Select Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text("Camera"),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text("Gallery"),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canProceedStep1() {
    return _selectedIdType != null &&
        _idNumberController.text.trim().isNotEmpty &&
        _idProofImage != null &&
        _profilePhoto != null;
  }

  bool _canProceedStep2() {
    return _selectedVehicleType != null &&
        _licensePlateController.text.trim().isNotEmpty &&
        _selectedFuelType != null;
  }

  Future<void> _submitKyc() async {
    if (!_canProceedStep1() || !_canProceedStep2()) {
      showToast(message: 'Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Submit KYC (Step 1 data)
      final kycResponse = await _authRepo.submitDriverKycNew(
        idProofType: _selectedIdType!,
        idProofNumber: _idNumberController.text.trim(),
        idProofImage: _idProofImage!,
        profilePhoto: _profilePhoto!,
      );

      if (kycResponse['success'] != true) {
        throw Exception(kycResponse['message'] ?? 'Failed to submit ID proof');
      }

      // Submit Vehicle Details (Step 2 data)
      int? vehicleYear;
      final yearText = _vehicleYearController.text.trim();
      if (yearText.isNotEmpty) {
        vehicleYear = int.tryParse(yearText);
      }

      final vehicleResponse = await _authRepo.submitVehicleDetails(
        ownerName: db.driver?.name ?? '',
        registeringAuthority: '',
        vehicleType: _selectedVehicleType!,
        fuelType: _selectedFuelType!,
        vehicleAge: vehicleYear != null ? (DateTime.now().year - vehicleYear) : 0,
        vehicleImage: _vehicleImage,
        licensePlate: _licensePlateController.text.trim(),
        vehicleMake: _vehicleMakeController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (vehicleResponse['success'] == true) {
        // Refresh driver status from backend and update local storage
        final newKycStatus = await _authRepo.refreshAndUpdateDriverStatus();
        
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ ✅ KYC SUBMISSION COMPLETE');
        debugPrint('║ New kycStatus: $newKycStatus');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        
        setState(() => _isLoading = false);
        showToast(message: 'KYC submitted successfully! Awaiting approval.');
        
        // Navigate to approval screen
        Get.offAllNamed(AppRoutes.approvel);
      } else {
        setState(() => _isLoading = false);
        showToast(message: vehicleResponse['message'] ?? 'Failed to submit vehicle details');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('KYC submission error: $e');
      showToast(message: 'Failed to submit KYC. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Get.back();
            }
          },
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          _currentStep == 0 ? "ID Verification" : "Vehicle Details",
          style: const TextStyle(fontSize: 18, color: AppColors.textColor),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                ),
              ),

              // Bottom button
              _buildBottomButton(),
            ],
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

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _stepCircle(0, "1", "ID Proof"),
          _stepLine(0),
          _stepCircle(1, "2", "Vehicle"),
          _stepLine(1),
          _stepCircle(2, "3", "Approval"),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String number, String label) {
    bool isActive = _currentStep >= step;
    bool isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      number,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(int step) {
    bool isActive = _currentStep > step;
    return Container(
      height: 3,
      width: 40,
      color: isActive ? AppColors.primary : Colors.grey.shade300,
    );
  }

  // ==================== STEP 1: ID PROOF ====================
  Widget _buildStep1() {
    final driver = db.driver;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver Info (Read-only)
        _sectionTitle("Driver Information"),
        _readOnlyField("Name", driver?.name ?? ""),
        _readOnlyField("Email", driver?.email ?? ""),
        _readOnlyField("Phone", driver?.mobile ?? ""),

        const SizedBox(height: 24),

        // ID Proof Section
        _sectionTitle("ID Proof *"),
        const SizedBox(height: 8),

        // ID Type Dropdown
        DropdownButtonFormField<String>(
          value: _selectedIdType,
          decoration: _inputDecoration("Select ID Type"),
          items: _idTypes.map((type) {
            return DropdownMenuItem(
              value: type['value'],
              child: Text(type['label']!),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedIdType = value),
        ),

        const SizedBox(height: 16),

        // ID Number
        TextField(
          controller: _idNumberController,
          decoration: _inputDecoration("ID Number *"),
        ),

        const SizedBox(height: 16),

        // ID Proof Image
        _imageUploadBox(
          "Upload ID Proof Image *",
          _idProofImage,
          () => _pickImage('id_proof'),
        ),

        const SizedBox(height: 24),

        // Profile Photo
        _sectionTitle("Profile Photo *"),
        const SizedBox(height: 8),
        _imageUploadBox(
          "Upload Profile Photo",
          _profilePhoto,
          () => _pickImage('profile'),
          isCircular: true,
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ==================== STEP 2: VEHICLE INFO ====================
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Vehicle Type *"),
        const SizedBox(height: 8),

        // Vehicle Type Dropdown
        DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          decoration: _inputDecoration("Select Vehicle Type"),
          items: _vehicleTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) => setState(() => _selectedVehicleType = value),
        ),

        const SizedBox(height: 16),

        // License Plate
        _sectionTitle("License Plate / Registration Number *"),
        const SizedBox(height: 8),
        TextField(
          controller: _licensePlateController,
          decoration: _inputDecoration("Enter license plate number"),
          textCapitalization: TextCapitalization.characters,
        ),

        const SizedBox(height: 16),

        // Vehicle Make
        _sectionTitle("Vehicle Make (Brand)"),
        const SizedBox(height: 8),
        TextField(
          controller: _vehicleMakeController,
          decoration: _inputDecoration("e.g. Toyota, Honda, BMW"),
        ),

        const SizedBox(height: 16),

        // Vehicle Model
        _sectionTitle("Vehicle Model"),
        const SizedBox(height: 8),
        TextField(
          controller: _vehicleModelController,
          decoration: _inputDecoration("e.g. Camry, Civic, X5"),
        ),

        const SizedBox(height: 16),

        // Vehicle Year
        _sectionTitle("Manufacturing Year"),
        const SizedBox(height: 8),
        TextField(
          controller: _vehicleYearController,
          decoration: _inputDecoration("e.g. 2020"),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 16),

        // Fuel Type
        _sectionTitle("Fuel Type *"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedFuelType,
          decoration: _inputDecoration("Select Fuel Type"),
          items: _fuelTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) => setState(() => _selectedFuelType = value),
        ),

        const SizedBox(height: 16),

        // Vehicle Image
        _sectionTitle("Vehicle Photo"),
        const SizedBox(height: 8),
        _imageUploadBox(
          "Upload Vehicle Photo",
          _vehicleImage,
          () => _pickImage('vehicle'),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : _onNextPressed,
            child: Text(
              _currentStep == 0 ? "Next" : "Submit",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentStep == 0) {
      if (!_canProceedStep1()) {
        showToast(message: 'Please fill all required fields and upload images');
        return;
      }
      setState(() => _currentStep = 1);
    } else {
      if (!_canProceedStep2()) {
        showToast(message: 'Please fill all required vehicle details');
        return;
      }
      _submitKyc();
    }
  }

  // ==================== HELPER WIDGETS ====================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _imageUploadBox(
    String label,
    File? image,
    VoidCallback onTap, {
    bool isCircular = false,
  }) {
    if (isCircular) {
      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: DottedBorder(
            options: CircularDottedBorderOptions(
              color: AppColors.primary,
              dashPattern: const [6, 6],
              strokeWidth: 2,
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: image != null
                  ? ClipOval(
                      child: Image.file(image, fit: BoxFit.cover, width: 120, height: 120),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 32, color: AppColors.primary),
                        SizedBox(height: 4),
                        Text("Add Photo", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(12),
          color: AppColors.primary,
          dashPattern: const [6, 6],
          strokeWidth: 2,
        ),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}
