
import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget widget;
  final EdgeInsetsGeometry? padding; // optional custom padding
  final Color? color; // <-- new optional color parameter

  const CustomButton({
    super.key,
    required this.onTap,
    required this.widget,
    this.padding,
    this.color, // <-- add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
      color: Colors.white,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color ?? AppColors.primary, // <-- dynamic with default fallback
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: widget,
        ),
      ),
    );
  }
}



class ConfirmButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? bg;
  final Widget label;

  const ConfirmButton({
    super.key,
    required this.onTap,
    required this.label,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;
    final Color effectiveBg = bg ?? Colors.grey[300]!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isEnabled ? effectiveBg : effectiveBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          alignment: Alignment.center,
          child: label,
        ),
      ),
    );
  }
}
