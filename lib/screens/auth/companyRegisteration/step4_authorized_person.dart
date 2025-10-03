import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

import 'company_registration_view.dart';

class Step4AuthorizedPerson extends StatelessWidget {
  final CompanyRegistrationController controller;
  const Step4AuthorizedPerson({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormWidgets.buildFormCard(
      formKey: controller.formKeyStep4,
      titleKey: 'auth_person_title', // New translation key
      subtitleKey: 'auth_person_subtitle', // New translation key
      icon: Icons.person_outline, // Icon from image_7e11c9.png
      fields: [
        // Full Name
        FormWidgets.buildTextField(
          controller: controller.fullNameController,
          label: 'full_name_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // Position
        FormWidgets.buildTextField(
          controller: controller.positionController,
          label: 'position_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // Phone Number
        FormWidgets.buildTextField(
          controller: controller.authPhoneController,
          label: 'phone_label'.tr,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Email
        FormWidgets.buildTextField(
          controller: controller.authEmailController,
          label: 'email_label'.tr,
          keyboardType: TextInputType.emailAddress,
          validator: controller.emailValidator,
        ),
      ],
      onNextPressed: controller.nextStep,
      buttonTextKey: 'next',
    );
  }
}