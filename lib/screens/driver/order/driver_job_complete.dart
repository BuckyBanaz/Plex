import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/driver/home/driver_home_screen.dart';
import 'package:plex_user/screens/driver/dashboard/driver_dashboard_screen.dart';

class DriverJobCompleteScreen extends StatelessWidget {
  final double amount;
  final String paymentMethod;

  const DriverJobCompleteScreen({
    Key? key,
    required this.amount,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Large success circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title with emoji
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🎉', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 8),
                  Text(
                    'Trip Completed!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Subtext
              const Text(
                "You've successfully completed the delivery.\nThe fare has been added to your earnings.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // Fare Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Fare',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    // SizedBox(height: 8),
                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: paymentMethod.toLowerCase() == 'cod'
                    //         ? Colors.green.shade100
                    //         : Colors.blue.shade100,
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     paymentMethod.toUpperCase(),
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w700,
                    //       color: paymentMethod.toLowerCase() == 'cod'
                    //           ? Colors.green.shade800
                    //           : Colors.blue.shade800,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              const Spacer(),

              // Back to Home button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => DriverMainScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // View Earnings button
              TextButton(
                onPressed: () {
                  // Navigate to earnings screen if available
                  Get.offAll(() => DriverMainScreen());
                },
                child: Text(
                  "View My Earnings",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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
