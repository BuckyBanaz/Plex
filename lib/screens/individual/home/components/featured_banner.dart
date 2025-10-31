import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_assets.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  // Controller to manage the pages
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Let's assume we have 4 banners to show
  final int _bannerCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The PageView for swiping through banners
        SizedBox(
          height: 22.h, // Set a height for the banner area
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerCount,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              // We return the actual banner widget here
              return const FeaturedBanner();
            },
          ),
        ),
        SizedBox(height: 2.h),

        // The Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerCount, (index) => buildDot(index: index)),
        ),
      ],
    );
  }

  // Helper widget to build a single dot
  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: _currentPage == index ? 8 : 6,
      width: _currentPage == index ? 20 : 6, // Active dot is wider
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.primarySwatch.shade50,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}




class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding to prevent the banner from touching screen edges
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(20.2),
          border: Border.all(color: AppColors.primarySwatch.shade50, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Main content row
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    // Left side: Text and Timer Graphic
                    Expanded(
                      flex: 5, // Takes more space
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "getReady".tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            "moveOn".tr,
                            style: TextStyle(
                              fontSize: 18.sp,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Timer Graphic
                          DonutTimerExact(timer: 'timerValue'.tr,),
                        ],
                      ),
                    ),
                    // Right side: Scooter Image
                    Expanded(
                      flex: 5, // Takes less space
                      child: Image.asset(
                        AppAssets.banner, // Make sure you have an image here
                        fit: BoxFit.contain,
                        // Fallback in case image fails to load
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.delivery_dining,
                            size: 20.w,
                            color: AppColors.primarySwatch,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned "Book now!" button
              Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 1.h,
                end: 4.w, // 'right' की जगह 'end' का उपयोग करें
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "bookNow".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class DonutTimerExact extends StatelessWidget {
  final String timer;
  const DonutTimerExact({

    super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: CustomPaint(
        painter: _DonutPainter(),
        child: Center(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: timer,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: "min".tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 20.0; // Adjusted for better visuals like in the previous example
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    const orangePercentage = 0.25; // 25% is orange

    // 1. Define the paint for the ORANGE arc
    final orangePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Makes the ends of the arc rounded

    // Define the angle for the orange arc (top 25%)
    const orangeStartAngle = -math.pi / 2; // Start at 12 o'clock
    const orangeSweepAngle = 2 * math.pi * orangePercentage;

    // Draw the orange arc
    canvas.drawArc(rect, orangeStartAngle, orangeSweepAngle, false, orangePaint);


    // 2. Define the paint for the BLACK arc
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // The black arc starts where the orange one ends
    final blackStartAngle = orangeStartAngle + orangeSweepAngle;

    // The black arc sweeps for the rest of the circle
    final blackSweepAngle = 2 * math.pi * (1.0 - orangePercentage);

    // Draw the black arc
    canvas.drawArc(rect, blackStartAngle, blackSweepAngle, false, blackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}