import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconly/iconly.dart';
import '../../../../constant/app_colors.dart';
import '../../../../modules/controllers/location/location_permission_controller.dart';

class TopBar extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool showLanguageButton;

  const TopBar({
    super.key,
    this.padding,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.showLanguageButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.put(LocationController());
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          Icon(
            IconlyBold.location,
            color: iconColor ?? AppColors.primary,
            size: 35,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick Up From',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color:
                        titleColor ?? Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                  locationController.currentAddress.value, // Controller se value lein
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor ?? Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),

          if (showLanguageButton) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'عرب',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
