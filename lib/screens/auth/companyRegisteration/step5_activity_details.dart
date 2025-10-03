import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

import '../../../../constant/app_colors.dart';
import 'company_registration_view.dart';

class Step5ActivityDetails extends StatelessWidget {
  final CompanyRegistrationController controller;
  const Step5ActivityDetails({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final employeeCounts = [
      '1-10_employees',
      '11-50_employees',
      '51-100_employees',
      '101-500_employees',
      '500+_employees',
    ];

    final shipmentVolumes = [
      '1-10_shipments_monthly',
      '11-50_shipments_monthly',
      '51-100_shipments_monthly',
      '101-500_shipments_monthly',
      '500+_shipments_monthly',
    ];

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: controller.formKeyStep5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader('activity_details_title', 'activity_details_subtitle'),

              // Employee Count
              _buildSelector(
                label: 'employee_count_label'.tr, // New translation key
                hint: 'select_employee_count'.tr, // New translation key
                value: controller.selectedEmployeeCount,
                options: employeeCounts,
                isDropdown: true,
              ),
              const SizedBox(height: 24),

              // Shipment Volume
              _buildSelector(
                label: 'shipment_volume_label'.tr, // New translation key
                hint: 'select_shipment_volume'.tr, // New translation key
                value: controller.selectedShipmentVolume,
                options: shipmentVolumes,
                isDropdown: true,
              ),
              const SizedBox(height: 24),

              // Review Section
              _buildReviewSection(controller),
              const SizedBox(height: 24),

              // Create Account Button (Final Step)
              FormWidgets.buildNextButton(
                onPressed: controller.nextStep,
                buttonText: 'create_account'.tr, // New translation key
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String titleKey, String subtitleKey) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.receipt_long, // Icon from image_7e14ae.png
            color: AppColors.primary,
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: Text(
            titleKey.tr,
            style: Get.textTheme.titleLarge!.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            subtitleKey.tr,
            style: Get.textTheme.bodyMedium!
                .copyWith(color: AppColors.textPrimary.withOpacity(0.8)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSelector({
    required String label,
    required String hint,
    required Rx<String?> value,
    required List<String> options,
    required bool isDropdown,
  }) {
    // Note: The images show a radio-button style selector, but a DropdownButtonFormField is often more practical.
    // I'll provide the dropdown implementation for consistency with the existing code structure.
    // If you need the exact segmented button style, that requires a different custom widget.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* ${label}',
          style: Get.textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimary.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => DropdownButtonFormField<String>(
            value: value.value,
            items: options
                .map((option) => DropdownMenuItem(
              value: option,
              child: Text(option.tr,
                  style: const TextStyle(color: Colors.black)),
            ))
                .toList(),
            onChanged: (String? newValue) {
              value.value = newValue;
            },
            style: Get.textTheme.bodyMedium!.copyWith(color: Colors.black),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (val) => val == null ? 'Required field'.tr : null,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(CompanyRegistrationController controller) {
    // Hardcoded example data from the image is used here for simplicity.
    // In a real app, this should pull actual data from the controller.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'review_data_title'.tr, // New translation key
            style: Get.textTheme.titleMedium!.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: AppColors.primary),
          _buildReviewItem('company_name_label', 'sldkskl'),
          _buildReviewItem('business_type_label', 'joint_stock'.tr),
          _buildReviewItem('email_label', 'company@ex.com'),
          _buildReviewItem('phone_label', '+9667012345678'),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String labelKey, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${labelKey.tr}:',
            style: Get.textTheme.bodyMedium!
                .copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: Get.textTheme.bodyMedium!
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}