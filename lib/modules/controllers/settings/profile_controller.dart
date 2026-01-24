import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:plex_user/models/user_models.dart';
import 'package:plex_user/modules/controllers/booking/search_driver_controller.dart';

import '../../../constant/app_colors.dart';
import '../../../models/driver_user_model.dart';
import '../../../services/domain/service/api/api_import.dart';
import '../../../services/domain/service/app/app_service_imports.dart';

class ProfileController extends GetxController{
  final DatabaseService db = Get.find<DatabaseService>();
  final DeviceInfoService deviceInfoService = Get.find<DeviceInfoService>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<DriverUserModel?> currentDriver = Rx<DriverUserModel?>(null);
  final Rx<bool> isLoading = false.obs;
  final RxBool loading = false.obs;

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
      Get.snackbar(
        "Error",
        "Passwords do not match",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
      return;
    }

    loading.value = true;

    // TODO: Replace with real API call
    await Future.delayed(const Duration(seconds: 1));

    loading.value = false;

    Get.snackbar(
      "Success",
      "Password reset successfully",
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
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
                Get.snackbar(
                  "Reset Link Sent",
                  "Link sent to ${emailCtrl.text.trim()}",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue.shade50,
                  colorText: Colors.blue.shade800,
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

  @override
  void onClose() {
    newPass.dispose();
    confirmPass.dispose();
    newPassFocus.dispose();
    confirmPassFocus.dispose();
    super.onClose();
  }
}