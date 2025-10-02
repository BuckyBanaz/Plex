import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constant/app_colors.dart';
import '../../modules/contollers/company_registration/company_registration_controller.dart';


class CompanyRegistrationView extends GetView<CompanyRegistrationController> {
  const CompanyRegistrationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CompanyRegistrationController());
    final isArabic = Get.locale?.languageCode == 'ar';

    final businessTypes = [
      'limited_liability',
      'joint_stock',
      'partnership',
      'sole_proprietorship',
      'government_entity',
      'non_profit',
    ];

    final businessSectors = [  'Construction',
      'Technology',
      'Finance',
      'Logistics',
      'Healthcare',]; // Example sectors

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isArabic),
              _buildProgressIndicator(),
              _buildFormCard(context, businessTypes, businessSectors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment:
        isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentGeometry.topLeft,

            child: Image.asset(
              "assets/images/logo.png",
              width: 120,
            ),
          ),
          Text(
            'registration_title'.tr,
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'registration_subtitle'.tr,
            style: Get.textTheme.bodyLarge!
                .copyWith(color: AppColors.textPrimary.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.2,
                  backgroundColor: AppColors.cardBg,
                  color: AppColors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'step_progress'.trParams({'step': '1', 'total': '5'}),
                style: Get.textTheme.bodyMedium!
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, List<String> businessTypes, List<String> businessSectors) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(Icons.account_balance,color: AppColors.primary,),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Text(
                'company_info_title'.tr,
                style: Get.textTheme.titleLarge!.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'company_info_subtitle'.tr,
                style: Get.textTheme.bodyMedium!
                    .copyWith(color: AppColors.textPrimary.withOpacity(0.8)),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: controller.companyNameController,
              label: 'company_name_label'.tr,
              hint: 'company_name_hint'.tr,
              validator: (value) => value!.isEmpty ? 'Required field'.tr : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.companyNameEnController,
              label: 'company_name_en_label'.tr,
              validator: (value) => value!.isEmpty ? 'Required field'.tr : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'business_type_label'.tr,
              hint: 'select_business_type'.tr,
              value: controller.selectedBusinessType,
              items: businessTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.tr, style: const TextStyle(color: Colors.black)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'business_sector_label'.tr,
              hint: 'select_sector'.tr,
              value: controller.selectedBusinessSector,
              items: businessSectors.map((sector) => DropdownMenuItem(
                value: sector,
                child: Text(sector.tr, style: const TextStyle(color: Colors.black)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.commercialRegisterController,
              label: 'commercial_register_label'.tr,
              hint: '30209320',
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Required field'.tr : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.taxRegisterController,
              label: 'tax_register_label'.tr,
              hint: '89232983294892',
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Required field'.tr : null,
            ),
            const SizedBox(height: 24),
            Obx(
                  () => ElevatedButton(
                onPressed: controller.isNextButtonEnabled.value
                    ? controller.nextStep
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isNextButtonEnabled.value
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('next'.tr, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      textDirection: Get.locale?.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required Rx<String?> value,
    required List<DropdownMenuItem<String>> items,
  }) {
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
            items: items,
            onChanged: (String? newValue) {
              value.value = newValue;
            },
            style: const TextStyle(color: Colors.black),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
            ),
            validator: (val) => val == null ? 'Required field'.tr : null,
          ),
        ),
      ],
    );
  }
}