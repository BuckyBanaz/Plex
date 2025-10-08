import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plex_user/screens/auth/companyRegisteration/step1_company_info.dart';
import 'package:plex_user/screens/auth/companyRegisteration/step2_contact_info.dart';
import 'package:plex_user/screens/auth/companyRegisteration/step3_address.dart';
import 'package:plex_user/screens/auth/companyRegisteration/step4_authorized_person.dart';
import 'package:plex_user/screens/auth/companyRegisteration/step5_activity_details.dart';
import '../../../constant/app_colors.dart';
import '../../../modules/contollers/company_registration/company_registration_controller.dart';

class CompanyRegistrationScreen extends StatelessWidget {
  const CompanyRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompanyRegistrationController());
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isArabic: isArabic),
            const SizedBox(height: 16),
            Obx(
              () => _ProgressIndicator(
                currentStep: controller.currentPage.value,
                totalSteps: controller.totalSteps,
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  controller.currentPage.value = index + 1;
                },
                children: [
                  Step1CompanyInfo(controller: controller),
                  Step2ContactInfo(controller: controller),
                  Step3Address(controller: controller),
                  Step4AuthorizedPerson(controller: controller),
                  Step5ActivityDetails(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isArabic;
  const _Header({Key? key, required this.isArabic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment:
            // isArabic ? CrossAxisAlignment.end :
            CrossAxisAlignment.center,
        children: [
          // Placeholder for Logo
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset('assets/images/logo.png', width: 120),
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
            style: Get.textTheme.bodyLarge!.copyWith(
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _ProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressValue = currentStep / totalSteps;
    final progressPercentage = (progressValue * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: AppColors.cardBg,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${progressPercentage}%',
            style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'step_progress'.trParams({
              'step': '$currentStep',
              'total': '$totalSteps',
            }),
            style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Utility widgets for form fields
class FormWidgets {
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
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
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator:
              validator ??
              (value) => value!.isEmpty ? 'Required field'.tr : null,
        ),
      ],
    );
  }

  static Widget buildDropdown({
    required String label,
    required String hint,
    required Rx<String?> value,
    required List<DropdownMenuItem<String>> items,
    String? Function(String?)? validator, // <- changed type and made optional
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
            style: Get.textTheme.bodyMedium!.copyWith(color: Colors.black),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
            // use provided validator or fallback to the default required check
            validator:
                validator ?? (val) => val == null ? 'Required field'.tr : null,
          ),
        ),
      ],
    );
  }

  static Widget buildNextButton({
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primary,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText.tr,
              style: Get.textTheme.titleMedium!.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: AppColors.textPrimary,
              textDirection: Get.locale?.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHeader(
    String titleKey,
    String subtitleKey,
    IconData icon,
  ) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: Text(
            titleKey.tr,
            style: Get.textTheme.titleLarge!.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            subtitleKey.tr,
            style: Get.textTheme.bodyMedium!.copyWith(
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static Widget buildFormCard({
    required GlobalKey<FormState> formKey,
    required String titleKey,
    required String subtitleKey,
    required IconData icon,
    required List<Widget> fields,
    required VoidCallback onNextPressed,
    required String buttonTextKey,
  }) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(titleKey, subtitleKey, icon),
              ...fields,
              const SizedBox(height: 24),
              buildNextButton(
                onPressed: onNextPressed,
                buttonText: buttonTextKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
