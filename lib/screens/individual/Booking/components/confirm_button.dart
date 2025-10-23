import 'package:flutter/material.dart';

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
