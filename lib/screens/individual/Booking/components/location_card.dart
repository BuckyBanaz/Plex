import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';

class LocationCard extends StatelessWidget {
  final VoidCallback onTap;
  final String? location;
  final String? fullLocation;
  const LocationCard({super.key, required this.onTap, required this.location, this.fullLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3E7),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // 1. Remove MainAxisAlignment.spaceBetween
            children: [
              // 2. Place Icon and SizedBox as direct children
               Icon(IconlyLight.location, color: AppColors.primary, size: 20),
              const SizedBox(width: 3.0),

              // 3. Wrap the Text with Expanded
              Expanded(
                child: Text(
                  location ?? '"Lal Khothi, Jaipur"',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // 4. Add overflow handling
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // 5. Place the TextButton as the last child
              TextButton(
                onPressed: onTap,
                child:  Text(
                  "change".tr,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            fullLocation ?? "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}