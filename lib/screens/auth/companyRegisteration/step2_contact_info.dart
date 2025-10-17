import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/validators/validators.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

import '../../widgets/custom_text_field.dart';
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
        CustomTextField(
          controller: controller.emailController,
          label: 'email_label'.tr, // New translation key
          hint: 'company@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
        ),
        const SizedBox(height: 16),

        // Password
        CustomTextField(
          controller: controller.passwordController,
          label: 'password_label'.tr, // New translation key
          hint: 'enter_strong_password'.tr, // New translation key
          isPassword: true,
          validator: passwordValidator,
        ),
        const SizedBox(height: 16),

        // Confirm Password
        CustomTextField(
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
        PhoneTextField(
          controller: controller.phoneController,
          label: 'phone_label'.tr, // New translation key
          hint: '512345678',
          // keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Website (Optional - assuming it's not strictly required by the red asterisk)
        CustomTextField(
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