import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../modules/controllers/payment/user_payment_controller.dart';

class CardsCarousel extends StatelessWidget {
  final UserPaymentController controller;
  final VoidCallback onTap;
  const CardsCarousel({super.key, required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {


    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Saved Cards",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              
              GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Icon(Icons.add,color: AppColors.primary,),
                    Text("Add More Card",style: TextStyle(color: AppColors.primary),)
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.cards.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final card = controller.cards[index];


              return AnimatedBuilder(
                animation: controller.pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (controller.pageController.position.haveDimensions) {
                    double page = controller.pageController.page ?? controller.currentPage.value.toDouble();
                    double pageDiff = (page - index).abs();

                    scale = (1 - (pageDiff * 0.15)).clamp(0.85, 1.0);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: _MyCardWidget(card: card),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dot Indicators
        Obx(
              () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildIndicators(controller.cards.length, controller.currentPage.value),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIndicators(int count, int currentIndex) {
    return List.generate(count, (index) {
      return Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: currentIndex == index
              ? Colors.black87
              : Colors.grey.shade400,
        ),
      );
    });
  }
}


class _MyCardWidget extends StatelessWidget {
  final Map<String, String> card;
  const _MyCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Color(int.parse(card['color']!));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [

          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: _CardWavePainter(waveColor: Colors.white.withOpacity(0.2)),
              ),
            ),
          ),

          // Card Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/chip.png',
                    height: 40,
                    width: 40,
                  ),
                  const Spacer(),
                  Image.asset(
                    card['logo']!,
                    height: 40,
                    width: 50,
                  ),
                ],
              ),
              const Spacer(),
              // Card Number
              Text(
                card['cardNumber']!,
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              // Card Holder and Expiry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Card Holder
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Holder',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        card['cardHolder']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Expiry Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expires',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        card['expiryDate']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardWavePainter extends CustomPainter {
  final Color waveColor;

  _CardWavePainter({required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Bottom Wave (Right to Left)
    path.moveTo(size.width, size.height * 0.7); // Start slightly above bottom right
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.9, // Control point
      size.width * 0.5, size.height * 0.8,   // Mid point
    );
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.7, // Control point
      0, size.height * 0.8,                  // End point (bottom left)
    );
    path.lineTo(0, size.height);             // Move to bottom left corner
    path.lineTo(size.width, size.height);    // Move to bottom right corner
    path.close();
    canvas.drawPath(path, paint);

    // Reset path for a second, more subtle wave (Top Left to Right)
    final Path path2 = Path();
    path2.moveTo(0, size.height * 0.3); // Start slightly below top left
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.1, // Control point
      size.width * 0.5, size.height * 0.2,   // Mid point
    );
    path2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.4, // Control point
      size.width, size.height * 0.3,         // End point (top right)
    );
    path2.lineTo(size.width, 0);             // Move to top right corner
    path2.lineTo(0, 0);                      // Move to top left corner
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _CardWavePainter oldDelegate) {
    return oldDelegate.waveColor != waveColor;
  }
}