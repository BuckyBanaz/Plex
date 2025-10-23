import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/routes/appRoutes.dart';

class DeliveryCard extends StatelessWidget {
  const DeliveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg, // Dark background
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side icons + dashed line
          Column(
            children: [
              // Top icon (Collect)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              // Dashed line
              SizedBox(
                height: 40, // distance between icons
                child: CustomPaint(
                  painter: DashedLinePainter(),
                ),
              ),

              // Bottom icon (Delivery)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Right side text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collect from section
                Row(

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Collect from",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kilometer 6, 278H, Street 201R, Kroalkor Village, Unnamed Road, Jaipur (Raj.)",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: (){
                      Get.toNamed(AppRoutes.pickup);
                    }, icon: Icon(IconlyLight.edit,color: AppColors.primary,))
                  ],
                ),
                const SizedBox(height: 16),

                // Delivery to section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Delivery to",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(IconlyLight.user,color: AppColors.textColor,size: 16,),
                               SizedBox(width: 2,),
                               Text(
                                "Delivery to",
                                style: TextStyle(
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
                              Icon(IconlyLight.call,color: AppColors.textColor,size: 16,),
                              SizedBox(width: 2,),
                              Text(
                                "+91 XXXXXXXX",
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "2nd Floor 01, 25 Mao Tse Toung Blvd (245), Phnom Penh 12302, Jaipur (Raj.)",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: (){
                      Get.toNamed(AppRoutes.dropOff);
                    }, icon: Icon(IconlyLight.edit,color: AppColors.primary,))

                  ],
                ),
                const SizedBox(height: 20),

                // Bottom row (time + map)
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
                        children:  [
                          Icon(Icons.access_time, color: AppColors.textColor, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Take around 20 min",
                            style: TextStyle(color: AppColors.textColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Map View...')),
                        );
                      },
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

// Custom Painter for dashed vertical line
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
