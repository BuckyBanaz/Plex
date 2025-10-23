import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // Import Dio for proper error handling
import 'package:plex_user/common/Toast/toast.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../../../models/user_models.dart';

class AuthController extends GetxController {

  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final conPasswordController = TextEditingController();
  String? countryCode;

  // Form keys
  final loginKey = GlobalKey<FormState>();
  final signupKey = GlobalKey<FormState>();
  final signupDriverKey = GlobalKey<FormState>();

  // Focus nodes
  final nameFocus = FocusNode();
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
    // Validate the form first
    if (loginKey.currentState == null || !loginKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      isLoading.value = true;
      final user = await _authRepo.login(email: email, password: password);
      currentUser.value = user;

      showToast(message: "Login successful");
      clearControllers();

      // Defensive: userType could be null or different casing
      final userType = (user.userType ?? '').toLowerCase();

      if (userType == 'individual') {
        Get.offAllNamed(AppRoutes.userDashBoard);
      } else if (userType == 'driver') {
        Get.offAllNamed(AppRoutes.partnerHome);
      } else {
        // fallback route: handle unknown user types
        Get.offAllNamed(AppRoutes.userDashBoard);
      }

    } on DioError catch (dioErr) {
      final resp = dioErr.response?.data;
      final msg = resp is Map ? (resp['message'] ?? resp['error']) : dioErr.message;
      showToast(message: msg ?? 'Server is busy! Please try again later');
    } catch (e) {
      showToast(message: e.toString());
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
    final phone = "${countryCode ?? '+91'}${phoneController.text}";


    try {
      isSignupLoading.value = true;

      final message = await _authRepo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      showToast(message: message);
      // do not immediately clear if you want to show email on OTP screen;
      // but if you want them cleared here:
      clearControllers();

      // Navigate to OTP screen passing email
      Get.offAllNamed(AppRoutes.otp, arguments: email);
    } on DioError catch (dioErr) {
      final msg = dioErr.response?.data?['message'] ??
          dioErr.message ??
          'Registration failed';
      // Get.snackbar('Error', msg);
      showToast(message: '$msg');
    } catch (e) {
      showToast(message: ' Server is busy! Please try after sometimes');
      // Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
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

    try {
      isDriverLoading.value = true;
      final response = await _authRepo.registerDriver(
        name: name,
        email: email,
        password: password,
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
      showToast(message: ' Server is busy! Please try after sometimes');
    } catch (e) {
      print("❌ Error: $e");
      // Get.snackbar("Error", e.toString());
      showToast(message: ' Server is busy! Please try after sometimes');
    } finally {
      isDriverLoading.value = false;
    }
  }
}
