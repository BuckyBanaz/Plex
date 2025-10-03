import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // Import Dio for proper error handling
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

  // Focus nodes
  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final conPasswordFocus = FocusNode();

  // state
  final isLoading = false.obs;

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

  // Login

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    Get.offAllNamed(AppRoutes.otp,arguments: email);
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and password required");
      return;
    }

    try {
      isLoading.value = true;
      final user = await _authRepo.login(email: email, password: password);
      currentUser.value = user;
      Get.snackbar("Success", "Login successful");

      // Navigate to home/dashboard
      Get.offAllNamed(AppRoutes.home);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }





  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final conPass = conPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || conPass.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields.');
      return;
    }
    if (password != conPass) {
      Get.snackbar('Error', 'Passwords do not match.');
      return;
    }

    try {
      isLoading.value = true;

      final message = await _authRepo.register(
        name: name,
        email: email,
        password: password,
      );

      // Success
      Get.snackbar('Success', message);

      // Navigate to OTP screen if needed
      Get.offAllNamed(AppRoutes.otp, arguments: email);

    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }


}