import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/validators/validators.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

import '../../widgets/custom_text_field.dart';
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
        CustomTextField(
          controller: controller.fullNameController,
          hint: 'full_name'.tr,
          label: 'full_name_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // Position
        CustomTextField(
          controller: controller.positionController,
          hint: 'position'.tr,
          label: 'position_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // Phone Number
        PhoneTextField(
          controller: controller.authPhoneController,
          hint: 'authorized_phone'.tr,
          label: 'phone_label'.tr,
          // keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Email
        CustomTextField(
          controller: controller.authEmailController,
          label: 'email_label'.tr,
          hint: 'authorized_email'.tr,
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
        ),
      ],
      onNextPressed: controller.nextStep,
      buttonTextKey: 'next',
    );
  }
}