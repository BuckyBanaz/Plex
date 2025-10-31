import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/controllers/company_registration/company_registration_controller.dart';

import '../../widgets/custom_text_field.dart';
import '../compnents/selector_field.dart';
import 'company_registration_view.dart';

class Step1CompanyInfo extends StatelessWidget {
  final CompanyRegistrationController controller;
  const Step1CompanyInfo({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final businessTypes = [
      'limited_liability',
      'joint_stock',
      'partnership',
      'sole_proprietorship',
      'government_entity',
      'non_profit',
    ];

    final businessSectors = [
      'Construction',
      'Technology',
      'Finance',
      'Logistics',
      'Healthcare',
    ];

    return FormWidgets.buildFormCard(
      formKey: controller.formKeyStep1,
      titleKey: 'company_info_title',
      subtitleKey: 'company_info_subtitle',
      icon: Icons.assignment, // Changed icon to match image_7e0d72.png
      fields: [
        // Company name (AR)
        CustomTextField(
          controller: controller.companyNameController,
          label: 'company_name_label'.tr,
          hint: 'company_name_hint'.tr,
        ),
        const SizedBox(height: 16),

        // Company name (EN)
        CustomTextField(
          controller: controller.companyNameEnController,
          label: 'company_name_en_label'.tr,
          hint: 'e.g., Advanced Path Trading Company'.tr,
        ),
        const SizedBox(height: 16),

        // Business type
        SelectorField(
          label: 'business_type_label'.tr,
          hint: 'select_business_type'.tr,
          value: controller.selectedBusinessType,
          options: businessTypes,
          // items: businessTypes
          //     .map((type) => DropdownMenuItem(
          //   value: type,
          //   child: Text(type.tr,
          //       style: const TextStyle(color: Colors.black)),
          // ))
          //     .toList(),
          // validator: (val) =>
          // controller.selectedBusinessType.value == null ? 'Required field'.tr : null,
        ),
        const SizedBox(height: 16),

        // Business sector
        SelectorField(
          label: 'business_sector_label'.tr,
          hint: 'select_sector'.tr,
          value: controller.selectedBusinessSector,
          options: businessSectors,
          // items: businessSectors
          //     .map((sector) => DropdownMenuItem(
          //   value: sector,
          //   child: Text(sector.tr,
          //       style: const TextStyle(color: Colors.black)),
          // ))
          //     .toList(),
          // validator: (val) =>
          // controller.selectedBusinessSector.value == null ? 'Required field'.tr : null,
        ),
        const SizedBox(height: 16),

        // Commercial register
        CustomTextField(
          controller: controller.commercialRegisterController,
          label: 'commercial_register_label'.tr,
          hint: '1010123456',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Tax register
        CustomTextField(
          controller: controller.taxRegisterController,
          label: 'tax_register_label'.tr,
          hint: '300123456789003',
          keyboardType: TextInputType.number,
        ),
      ],
      onNextPressed: controller.nextStep,
      buttonTextKey: 'next',
    );
  }
}