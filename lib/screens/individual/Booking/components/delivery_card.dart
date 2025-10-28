import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/routes/appRoutes.dart';

class DeliveryCard extends StatelessWidget {
  final String collectLabel;
  final String collectAddress;
  final VoidCallback? onEditCollect;

  final String deliveryLabel;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;
  final VoidCallback? onEditDelivery;

  final String durationText;
  final VoidCallback? onMapViewTap;

  const DeliveryCard({
    super.key,
    required this.collectLabel,
    required this.collectAddress,
    this.onEditCollect,
    required this.deliveryLabel,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryAddress,
    this.onEditDelivery,
    required this.durationText,
    this.onMapViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left icons + dashed line
          Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.my_location, color: Colors.white, size: 18),
              ),
              SizedBox(
                height: 40,
                child: CustomPaint(painter: DashedLinePainter()),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.location_on, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Right text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collect from
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collectLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            collectAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onEditCollect != null)
                      IconButton(
                        onPressed: onEditCollect,
                        icon: Icon(IconlyLight.edit, color: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Delivery to
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deliveryLabel,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(IconlyLight.user, color: AppColors.textColor, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                deliveryName,
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(IconlyLight.call, color: AppColors.textColor, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                deliveryPhone,
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deliveryAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onEditDelivery != null)
                      IconButton(
                        onPressed: onEditDelivery,
                        icon: Icon(IconlyLight.edit, color: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bottom row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.textColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            durationText,
                            style: const TextStyle(color: AppColors.textColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onMapViewTap,
                      child: const Text(
                        "Map View",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
