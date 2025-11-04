import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // Import Dio for proper error handling
import 'package:plex_user/common/Toast/toast.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../../../models/driver_user_model.dart';
import '../../../models/user_models.dart';

class AuthController extends GetxController {

  // Controllers
  final nameController = TextEditingController();
  final licenseNoController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final conPasswordController = TextEditingController();
  String? countryCode;

  // Form keys
  final loginKey = GlobalKey<FormState>();
  final signupKey = GlobalKey<FormState>();
  final signupDriverKey = GlobalKey<FormState>();
  final forgotPasswordKey = GlobalKey<FormState>();

  // Focus nodes
  final nameFocus = FocusNode();
  final licenseFocus = FocusNode();
  final vehicleFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final conPasswordFocus = FocusNode();

  // state
  final isLoading = false.obs;
  final isSignupLoading = false.obs;
  final isDriverLoading = false.obs;

  // repo (resolved via Get)
  final AuthRepository _authRepo = AuthRepository();
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  Rx<DriverUserModel?> currentDriver = Rx<DriverUserModel?>(null);
  final selectedVehicle = Rx<String?>(null);
  final emailError = RxnString();
  final passwordError = RxnString();

  void clearFieldErrors() {
    emailError.value = null;
    passwordError.value = null;
  }
  final vehicles = [
    'Bike',
    'Car',
    'Van',
  ];
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    // dispose controllers & focus nodes
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    conPasswordController.dispose();

    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    conPasswordFocus.dispose();

    super.onClose();
  }

  /// Helper to clear fields (call this when you navigate back to login or when needed)
  void clearControllers() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    conPasswordController.clear();

    // optionally unfocus
    nameFocus.unfocus();
    phoneFocus.unfocus();
    emailFocus.unfocus();
    passwordFocus.unfocus();
    conPasswordFocus.unfocus();
  }

  Future<void> login() async {
    showToast(message: 'Login call.');
    if (loginKey.currentState == null || !loginKey.currentState!.validate()) {
      return;
    }

    clearFieldErrors();
    isLoading.value = true;

    try {
      await _authRepo.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      showToast(message: "Login successful");
      Get.offAllNamed(AppRoutes.location);
    } on DioError catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? '';
      if (msg.toLowerCase().contains('user not found')) {
        emailError.value = "User not found";
      } else if (msg.toLowerCase().contains('incorrect password')) {
        passwordError.value = "Incorrect password";
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      // 👇 Handle generic errors too (like the one thrown by AuthRepository)
      final msg = e.toString().toLowerCase();
      if (msg.contains('incorrect password')) {
        passwordError.value = "Incorrect password";
      } else if (msg.contains('user not found')) {
        emailError.value = "User not found";
      } else {
        showToast(message: 'Login failed. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> signup() async {
    // Validate signup form
    if (signupKey.currentState == null || !signupKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    // final phone = "${countryCode ?? '+91'}${phoneController.text}";
    final phone = "${phoneController.text}";

    try {
      isSignupLoading.value = true;

      final message = await _authRepo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      showToast(message: message);
      clearControllers();

      Get.offAllNamed(AppRoutes.otp, arguments: email);
    } on DioError catch (dioErr) {
      final msg = dioErr.response?.data?['message'] ??
          dioErr.message ??
          'Registration failed';
      showToast(message: '$msg');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.toLowerCase().contains('email already registered')) {
        emailError.value = "Email already registered";
        // ✅ re-run validation for UI update
        signupKey.currentState?.validate();
      } else {
        showToast(message: 'Signup failed. Please try again.');
      }
    }
    finally {
      isSignupLoading.value = false;
    }
  }

  Future<void> registerDriver() async {
    // Validate driver signup form
    if (signupDriverKey.currentState == null || !signupDriverKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final phone = phoneController.text;
    final licenseNo = licenseNoController.text;

    try {
      isDriverLoading.value = true;
      final response = await _authRepo.registerDriver(
        name: name,
        email: email,
        password: password,
          vehicleType: selectedVehicle.value!.toLowerCase() ?? '',
          licenseNo:licenseNo,
        phone: "${countryCode}${phone}"
      );

      print("✅ Driver registered: $response");
      // showToast(message: "Driver registered successfully!");
      clearControllers(); // optional
      Get.offAllNamed(AppRoutes.otp, arguments: email);
    } on DioError catch (dioErr) {
      final msg = dioErr.response?.data?['message'] ??
          dioErr.message ??
          'Driver registration failed';
      // Get.snackbar("Error", msg);
      showToast(message: msg);
    } catch (e) {
      print("❌ Error: $e");
      // Get.snackbar("Error", e.toString());
      showToast(message: ' Server is busy! Please try after sometimes');
    } finally {
      isDriverLoading.value = false;
    }
  }

  // Main method called by UI
  Future<void> submitForgotPassword() async {

    if (forgotPasswordKey.currentState == null || !forgotPasswordKey.currentState!.validate()) {
      return;
    }
    final email = emailController.text.trim();


    isLoading.value = true;

    try {
      final res = await _authRepo.forgotPassword(
        email: email,
      );

      isLoading.value = false;

      final bool success = res['success'] == true;
      final String message =
      (res['message']?.toString().isNotEmpty ?? false) ? res['message'].toString() : '';

      if (success) {
        // Show success dialog
        await Get.dialog(
          AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: Text(message.isNotEmpty
                ? message
                : 'Password reset link sent successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.back(); // go back to previous screen (login)
                },
                child: const Text('OK'),
              )
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        // API returned non-success
        Get.snackbar(
          'Something went wrong.',
          message.isNotEmpty ? message : 'Something went wrong.',
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isLoading.value = false;
      // Network / unexpected error
      Get.snackbar(
        'Failed to send reset link.',
        'Failed to send reset link. Please try again later.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
