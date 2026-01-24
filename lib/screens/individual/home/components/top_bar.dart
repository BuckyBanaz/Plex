import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import '../../../../constant/app_colors.dart';
import '../../../../modules/controllers/location/location_permission_controller.dart';

class TopBar extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool showIcon;
  final IconButton? iconButton;
  final VoidCallback? onTap;

  const TopBar({
    super.key,
    this.padding,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.showIcon = false,
    this.iconButton,
    this.onTap,
  });

  // ---------------------------
  // Extract Locality from Address
  // ---------------------------
  String _getLocality(String fullAddress) {
    try {
      return fullAddress.split(",").first.trim();
    } catch (e) {
      return fullAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.put(LocationController());

    return Padding(
      padding:
      padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              IconlyBold.location,
              color: iconColor ?? AppColors.primary,
              size: 35,
            ),
            const SizedBox(width: 8),

            // -------------------------------
            //  TEXT SECTION (Title + Subtitle)
            // -------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final fullAddress =
                        locationController.currentAddress.value;

                    return Row(
                      children: [
                        Text(
                          showIcon
                              ? _getLocality(fullAddress) // when showIcon = TRUE
                              : 'pick_up_from'.tr,        // Default text
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: titleColor ?? Colors.black,
                          ),
                        ),

                        // dropdown arrow only when showIcon = false
                        if (!showIcon) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.keyboard_arrow_down_outlined,
                              color: titleColor),
                        ],
                      ],
                    );
                  }),

                  const SizedBox(height: 2),

                  Obx(() => Text(
                    locationController.currentAddress.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor ?? Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),

            // icon button visible when showIcon = true
            if (showIcon) ...[
              const SizedBox(width: 6),
              if (iconButton != null) iconButton!,
            ],
          ],
        ),
      ),
    );
  }
}
