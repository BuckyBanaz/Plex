import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

import 'company_registration_view.dart';

class Step2ContactInfo extends StatelessWidget {
  final CompanyRegistrationController controller;
  const Step2ContactInfo({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormWidgets.buildFormCard(
      formKey: controller.formKeyStep2,
      titleKey: 'contact_info_title', // New translation key
      subtitleKey: 'contact_info_subtitle', // New translation key
      icon: Icons.mail_outline, // Icon from image_7e0dc8.png
      fields: [
        // Email
        FormWidgets.buildTextField(
          controller: controller.emailController,
          label: 'email_label'.tr, // New translation key
          hint: 'company@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: controller.emailValidator,
        ),
        const SizedBox(height: 16),

        // Password
        FormWidgets.buildTextField(
          controller: controller.passwordController,
          label: 'password_label'.tr, // New translation key
          hint: 'enter_strong_password'.tr, // New translation key
          isPassword: true,
          validator: controller.passwordValidator,
        ),
        const SizedBox(height: 16),

        // Confirm Password
        FormWidgets.buildTextField(
          controller: controller.confirmPasswordController,
          label: 'confirm_password_label'.tr, // New translation key
          hint: 're_enter_password'.tr, // New translation key
          isPassword: true,
          validator: (value) {
            if (value!.isEmpty) return 'Required field'.tr;
            if (value != controller.passwordController.text) {
              return 'Passwords do not match'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone Number
        FormWidgets.buildTextField(
          controller: controller.phoneController,
          label: 'phone_label'.tr, // New translation key
          hint: '+966512345678',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Website (Optional - assuming it's not strictly required by the red asterisk)
        FormWidgets.buildTextField(
          controller: controller.websiteController,
          label: 'website_label'.tr, // New translation key
          hint: 'https://www.company.com',
          validator: (value) => null, // Not required
        ),
      ],
      onNextPressed: controller.nextStep,
      buttonTextKey: 'next',
    );
  }
}