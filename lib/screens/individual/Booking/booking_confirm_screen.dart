import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_assets.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../routes/appRoutes.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 2 seconds and navigate to home
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.userDashBoard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking Confirmed",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.bookingConfirm, height: 150),
            const SizedBox(height: 16),
            Text(
              "Congratulations! Your shipment has been placed",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.cardBg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
