
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart' show IconlyLight;

import '../../../constant/app_colors.dart';

/// Small model for a profile option
class ProfileOption {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  ProfileOption({required this.title, required this.icon, this.onTap});
}


/// A single option row widget
class ProfileOptionRow extends StatelessWidget {
  final ProfileOption option;
  const ProfileOptionRow({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10),
        child: Row(
          children: [
            // small rounded box with icon (matches orange icon in picture)
            Icon(option.icon, color: AppColors.primary, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


class ProfileHeader extends StatelessWidget {
  final String name;
  final String? driverId;
  final double? rating;
  final bool isDriver;
  final ImageProvider? profileImage;
  final bool isEdit;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    this.driverId,
    this.rating,
    this.isDriver = false,
    this.profileImage,
    this.isEdit = false,
    this.onEditPressed,
  });

  // Initials nikalne ka function
  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isDriver
          ? _buildDriverProfile() // Driver layout
          : _buildNormalProfile(),
    ); // Default column layout
  }

  // ---------------- DRIVER PROFILE (Row Layout) ----------------
  Widget _buildDriverProfile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: profileImage,
          child: profileImage == null
              ? Text(
            getInitials(name),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          )
              : null,
        ),
        const SizedBox(width: 12),

        // Name, ID, Rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (driverId != null)
                Text(
                  'VN – $driverId',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              if (rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        if (isEdit)
          GestureDetector(
            onTap: onEditPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                IconlyLight.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------- NORMAL USER PROFILE (Column Layout) ----------------
  Widget _buildNormalProfile() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: profileImage,
              child: profileImage == null
                  ? Text(
                getInitials(name),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              )
                  : null,
            ),
            if (isEdit)
              GestureDetector(
                onTap: onEditPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    IconlyLight.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

