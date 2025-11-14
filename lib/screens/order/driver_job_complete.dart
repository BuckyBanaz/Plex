import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart';

// Drop this file into your lib/ folder and import where you need it:
// Navigator.push(context, MaterialPageRoute(builder: (_) => TripCompletedScreen(amount: 125.50, paymentMethod: 'Online')));

class DriverJobCompleteScreen extends StatelessWidget {
  final double amount;
  final String paymentMethod;

  const DriverJobCompleteScreen({Key? key, required this.amount, required this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colors taken to match the reference design
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Large orange check circle
                Container(
                  width: 120,
                  height: 120,
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Title with emoji
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🎉', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 8),
                    Text(
                      'Trip Completed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Subtext lines
                const Text(
                  "You've successfully completed the trip.\nThe fare has been added to your earnings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Total Fare label + amount
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      const TextSpan(
                        text: 'Total Fare ',
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: '\$${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  paymentMethod,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
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
