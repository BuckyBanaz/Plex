import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/models/user_models.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';

import '../../../constant/app_colors.dart';
import '../../../models/driver_user_model.dart';
import '../../../services/domain/service/api/api_import.dart';
import '../../../services/domain/service/app/app_service_imports.dart';
import '../../../services/domain/repository/repository_imports.dart';

class ProfileController extends GetxController{
  final DatabaseService db = Get.find<DatabaseService>();
  final DeviceInfoService deviceInfoService = Get.find<DeviceInfoService>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<DriverUserModel?> currentDriver = Rx<DriverUserModel?>(null);
  final Rx<bool> isLoading = false.obs;
  final RxBool loading = false.obs;
  final RxBool isUpdating = false.obs;

  // Edit Profile Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final dobController = TextEditingController();
  final editFormKey = GlobalKey<FormState>();

  final newPass = TextEditingController();
  final confirmPass = TextEditingController();
  final newPassFocus = FocusNode();
  final confirmPassFocus = FocusNode();
  final formKey = GlobalKey<FormState>();


  @override
  void onInit() {
    super.onInit();

    _loadUserData();
    token();

  }


Future<void> token() async {

    try{
      final deviceInfo = await deviceInfoService.getDeviceInfo();
      print("firebase token : ${deviceInfo.firebaseToken}");
    }catch(e){
      print("error: $e");
    }


}
  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;

      final type = db.userType;

      if (type == "individual"){
        final UserData = db.user;
        if (UserData != null) {
          currentUser.value = UserData;
          print("User:${currentUser.value?.name}");
        } else {
          print("No User data found in local DB.");
        }
      }else {
        final driverData = db.driver;

        if (driverData != null) {
          currentDriver.value = driverData;
          print("User:${currentDriver.value?.name}");
        } else {
          print("No Driver data found in local DB.");
        }
      }

    } catch (e) {
      print("Failed to load User data: $e");
    } finally {
      isLoading.value = false;
    }
  }
  void logoutUser(BuildContext context) {
    logout();
    // TODO: yahan logout logic add karo (e.g. FirebaseAuth.instance.signOut())
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
  }

  Future<void> resetPassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (newPass.text.trim() != confirmPass.text.trim()) {
      CustomSnackbar.error(
        "Passwords do not match",
        title: "Error",
      );
      return;
    }

    loading.value = true;

    // TODO: Replace with real API call
    await Future.delayed(const Duration(seconds: 1));

    loading.value = false;

    CustomSnackbar.success(
      "Password reset successfully",
      title: "Success",
    );

    // Optionally navigate back
    // Get.back();
  }

  void showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your registered email address. We’ll send you a reset link.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState!.validate()) {
                Get.back();
                CustomSnackbar.success(
                  "Link sent to ${emailCtrl.text.trim()}",
                  title: "Reset Link Sent",
                );
                // TODO: Call actual API to send reset link
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Send',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Initialize edit profile form with current user data
  void initEditProfile() {
    final isDriver = db.userType == 'driver';
    
    if (isDriver) {
      final driver = currentDriver.value;
      nameController.text = driver?.name ?? '';
      emailController.text = driver?.email ?? '';
      mobileController.text = driver?.mobile ?? '';
    } else {
      final user = currentUser.value;
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
      mobileController.text = user?.mobile ?? '';
    }
    dobController.text = '';
  }

  /// Update user profile via repository
  Future<bool> updateProfile() async {
    if (!editFormKey.currentState!.validate()) return false;

    isUpdating.value = true;

    try {
      final result = await _userRepository.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        dateOfBirth: dobController.text.isNotEmpty ? dobController.text.trim() : null,
      );

      if (result != null) {
        // Reload user data from local DB
        await _loadUserData();
        CustomSnackbar.success('Profile updated successfully');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      CustomSnackbar.error('Failed to update profile');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Check if profile has changes
  bool hasProfileChanges() {
    final isDriver = db.userType == 'driver';
    
    if (isDriver) {
      final driver = currentDriver.value;
      return nameController.text != (driver?.name ?? '') ||
          emailController.text != (driver?.email ?? '') ||
          mobileController.text != (driver?.mobile ?? '');
    } else {
      final user = currentUser.value;
      return nameController.text != (user?.name ?? '') ||
          emailController.text != (user?.email ?? '') ||
          mobileController.text != (user?.mobile ?? '');
    }
  }

  @override
  void onClose() {
    newPass.dispose();
    confirmPass.dispose();
    newPassFocus.dispose();
    confirmPassFocus.dispose();
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dobController.dispose();
    super.onClose();
  }
}