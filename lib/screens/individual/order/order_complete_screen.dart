// /screens/orders/order_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart'; // Apne app colors import karein

class OrderCompleteScreen extends StatelessWidget {
  const OrderCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              Image.asset(
                'assets/images/complete.png',
                height: 250,
              ),
              const Text(
                "Congratulations!",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Your delivery has been successfully completed.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),

              Text(
                "Thank you for choosing us - we appreciate your trust and\nlook forward to serving you again soon!",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}