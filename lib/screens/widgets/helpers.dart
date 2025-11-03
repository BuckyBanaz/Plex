import 'package:flutter/material.dart';

import '../../constant/app_colors.dart';

/// Reusable helper widget for the Info Section
class InfoColumnItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? titleSize;
  final double? subtitleSize;

  const InfoColumnItem(
      this.title,
      this.subtitle, {
        super.key,
        this.titleSize,
        this.subtitleSize,
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: titleSize ?? 13, // default 13 if not provided
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleSize ?? 15, // default 15 if not provided
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

