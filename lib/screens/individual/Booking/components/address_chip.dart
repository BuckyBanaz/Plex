import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart';

class AddressChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3E7) : Colors.white, // Orange bg
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[400]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
