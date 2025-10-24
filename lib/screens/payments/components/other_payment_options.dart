import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../modules/controllers/payment/user_payment_controller.dart';

class OtherPaymentOptions extends StatelessWidget {
  const OtherPaymentOptions({super.key});

  @override
  Widget build(BuildContext context) {

    final UserPaymentController c = Get.find<UserPaymentController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. टाइटल
          const Text(
            'Other Payment options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),


          Obx(() {
            return Column(
              children: c.paymentOptions.map((option) {
                final String name = option['name'];
                final dynamic logo = option['logo'];
                final bool isAsset = option['isAsset'];

                return ListTile(
                  contentPadding: EdgeInsets.zero,

                  leading: isAsset
                      ? Image.asset(
                    logo,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  )
                      : Icon(
                    logo,
                    color: Colors.grey.shade600,
                    size: 28,
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),

                  trailing: Radio<String>(
                    value: name,
                    groupValue: c.selectedPaymentOption.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        c.selectPaymentOption(newValue);
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {
                    c.selectPaymentOption(name);
                  },
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}