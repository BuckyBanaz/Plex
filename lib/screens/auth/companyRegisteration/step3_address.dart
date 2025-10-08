import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

import '../../widgets/custom_text_field.dart';
import 'company_registration_view.dart';

class Step3Address extends StatelessWidget {
  final CompanyRegistrationController controller;
  const Step3Address({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countries = [
      'Saudi Arabia',
      'United Arab Emirates',
      'Kuwait',
      'Qatar',
      'Bahrain',
      'Oman',
    ];

    return FormWidgets.buildFormCard(
      formKey: controller.formKeyStep3,
      titleKey: 'address_title', // New translation key
      subtitleKey: 'address_subtitle', // New translation key
      icon: Icons.location_on_outlined, // Icon from image_7e110c.png
      fields: [
        // Country
        FormWidgets.buildDropdown(
          label: 'country_label'.tr, // New translation key
          hint: 'select_country'.tr, // New translation key
          value: controller.selectedCountry,
          items: countries
              .map((country) => DropdownMenuItem(
            value: country,
            child: Text(country.tr,
                style: const TextStyle(color: Colors.black)),
          ))
              .toList(),
          validator: (val) =>
          controller.selectedCountry.value == null ? 'Required field'.tr : null,
        ),
        const SizedBox(height: 16),

        // City
        CustomTextField(
          controller: controller.cityController,
          hint: 'city'.tr,
          label: 'city_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // District
        CustomTextField(
          controller: controller.districtController,
          hint: 'district'.tr,
          label: 'district_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // Street
        CustomTextField(
          controller: controller.streetController,
          hint: 'street'.tr,
          label: 'street_label'.tr, // New translation key
        ),
        const SizedBox(height: 16),

        // Building Number and Postal Code in a Row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.buildingNumberController,
                label: 'building_no_label'.tr, // New translation key
                hint: 'building_number'.tr,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: controller.postalCodeController,
                label: 'postal_code_label'.tr, // New translation key
                hint: 'postal_code'.tr,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
      onNextPressed: controller.nextStep,
      buttonTextKey: 'next',
    );
  }
}
