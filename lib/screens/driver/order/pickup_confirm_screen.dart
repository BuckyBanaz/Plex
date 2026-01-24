import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart';

class PickupConfirmedScreen extends StatelessWidget {
  final String orderNumber;
  const PickupConfirmedScreen({super.key, this.orderNumber = "#A23456"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 100),

            // big orange circle with white check
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 64, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Title
            Text(
              "Pickup Confirmed",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                "The order has been successfully picked up.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13.5,
                  height: 1.25,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Order number
            Text(
              "Order Number:  -- $orderNumber",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            // spacer to push content up like screenshot
            const Spacer(),

            // Optional: a button to go to Home / Orders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Example: pop back or navigate to orders
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Back to Orders",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
