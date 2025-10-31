import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart'; // SVG के लिए इम्पोर्ट करें

class DeliveryNotificationCard extends StatelessWidget {

  final int deliveryCount;
  final VoidCallback? onViewDetails;

  const DeliveryNotificationCard({
    super.key,
    this.deliveryCount = 2,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), // इमेज के अनुसार पैडिंग
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$deliveryCount ${'deliveryOrdersFound'.tr}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onViewDetails,
                  child:  Text(
                    'viewDetails'.tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),


          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/box.svg',
                height: 50,
                width: 50,
                // colorFilter: const ColorFilter.mode(
                //   Color(0xFFFFF7ED),
                //   BlendMode.srcIn,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}