import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Get the current context
    final context = Get.context;
    if (context == null) return;

    // Dismiss any existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          title: title,
          message: message,
          icon: config.icon,
          iconColor: config.iconColor,
          onTap: onTap,
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: config.borderColor, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        elevation: 6,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: config.iconColor,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// Quick success snackbar
  static void success(String message, {String? title}) {
    show(
      title: title ?? 'success'.tr,
      message: message,
      type: SnackbarType.success,
    );
  }

  /// Quick error snackbar
  static void error(String message, {String? title}) {
    show(
      title: title ?? 'error'.tr,
      message: message,
      type: SnackbarType.error,
      duration: const Duration(seconds: 4),
    );
  }

  /// Quick warning snackbar
  static void warning(String message, {String? title}) {
    show(
      title: title ?? 'warning'.tr,
      message: message,
      type: SnackbarType.warning,
    );
  }

  /// Quick info snackbar
  static void info(String message, {String? title}) {
    show(
      title: title ?? 'info'.tr,
      message: message,
      type: SnackbarType.info,
    );
  }

  static _SnackbarConfig _getConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green.shade600,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_rounded,
          iconColor: Colors.red.shade600,
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_rounded,
          iconColor: Colors.orange.shade600,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_rounded,
          iconColor: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.08),
          borderColor: AppColors.primary.withOpacity(0.3),
        );
    }
  }
}

class _SnackbarConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  _SnackbarConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

class _SnackbarContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SnackbarContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Close button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
