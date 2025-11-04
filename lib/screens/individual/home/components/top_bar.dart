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
  final bool showLanguageButton;
  final bool showIcon;
  final IconButton? iconButton;
  final VoidCallback? onTap;

  const TopBar({
    super.key,
    this.padding,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.showLanguageButton = true,
    this.showIcon = false,  this.iconButton, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.put(LocationController());

    final bool isArabic = Get.locale?.languageCode == 'ar';
    final String languageButtonText = isArabic ? 'Eng' : 'عرب';

    return Padding(
      padding:
      padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: GestureDetector(
        onTap:onTap ,
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
                crossAxisAlignment: CrossAxisAlignment.start, // Yeh RTL mein "right" align ho jayega
                children: [
                  Row(
                    children: [
                      Text(
                        'pick_up_from'.tr, // TRANSLATION FIX: Hardcoded text ko .tr se badla
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color:
                          titleColor ?? Colors.black,
                        ),
                      ),
                      SizedBox(width: 3,),

                      Icon(Icons.keyboard_arrow_down_outlined)
                    ],
                  ),
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

            // if (showLanguageButton) ...[
            //   const SizedBox(width: 6),
            //   InkWell(
            //     onTap: () {
            //       // Yahaan language change ka logic daalein
            //       // Example:
            //       if (isArabic) {
            //         Get.updateLocale(const Locale('en', 'US'));
            //       } else {
            //         Get.updateLocale(const Locale('ar', 'SA'));
            //       }
            //     },
            //     child: Container(
            //       width: 36,
            //       height: 36,
            //       decoration: BoxDecoration(
            //         color: Colors.black,
            //         shape: BoxShape.circle,
            //       ),
            //       child: Center(
            //         child: Text(
            //           languageButtonText,
            //           style: const TextStyle(
            //             color: Colors.white,
            //             fontSize: 12,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ],

            if (showIcon) ...[
              const SizedBox(width: 6),

              ?iconButton
            ],

          ],
        ),
      ),
    );
  }
}