import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';

import '../../../constant/app_colors.dart';
import '../../../routes/appRoutes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final UserRepository repo = UserRepository();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 2 * 3.14).animate(_controller);

    // After 2 seconds -> check auth and navigate
    Timer(const Duration(seconds: 2), () {
      _navigateBasedOnAuth();
    });
  }

  Future<void> _navigateBasedOnAuth() async {
    final db = Get.find<DatabaseService>();
    final token = db.accessToken;
    
    debugPrint('╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🔍 SPLASH NAVIGATION CHECK');
    debugPrint('╠══════════════════════════════════════════════════════════════');
    debugPrint('║ Token available: ${token != null}');
    
    if (token == null || token.isEmpty) {
      debugPrint('║ ➡️ No token -> Login');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    
    final userType = db.userType;
    debugPrint('║ UserType: $userType');
    
    if (userType == 'driver') {
      // For drivers, refresh status from backend to get latest kycStatus
      String kycStatus = db.driver?.kycStatus ?? 'not_submitted';
      debugPrint('║ Local kycStatus: $kycStatus');
      
      // If not verified, refresh from backend to ensure we have latest
      if (kycStatus != 'verified') {
        try {
          debugPrint('║ 🔄 Refreshing status from backend...');
          final authRepo = Get.find<AuthRepository>();
          kycStatus = await authRepo.refreshAndUpdateDriverStatus();
          debugPrint('║ Updated kycStatus: $kycStatus');
        } catch (e) {
          debugPrint('║ ⚠️ Failed to refresh status: $e');
          // Use local status if refresh fails
          kycStatus = db.driver?.kycStatus ?? 'not_submitted';
        }
      }
      
      // Navigate based on kycStatus
      if (kycStatus == 'not_submitted' || kycStatus.isEmpty) {
        debugPrint('║ ➡️ KYC not submitted -> KYC screen');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        Get.offAllNamed(AppRoutes.kyc);
      } else if (kycStatus == 'verified') {
        final locationShown = db.isLocationScreenShown ?? false;
        if (locationShown) {
          debugPrint('║ ➡️ KYC verified -> Dashboard');
          debugPrint('╚══════════════════════════════════════════════════════════════');
          Get.offAllNamed(AppRoutes.driverDashBoard);
        } else {
          debugPrint('║ ➡️ KYC verified -> Location screen');
          debugPrint('╚══════════════════════════════════════════════════════════════');
          Get.offAllNamed(AppRoutes.location);
        }
      } else {
        // pending, awaiting_approval, rejected
        debugPrint('║ ➡️ KYC $kycStatus -> Approval screen');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        Get.offAllNamed(AppRoutes.approvel);
      }
    } else if (userType == 'individual') {
      final user = db.user;
      if (user != null && user.name.isNotEmpty) {
        final locationShown = db.isLocationScreenShown ?? false;
        if (locationShown) {
          debugPrint('║ ➡️ User -> Dashboard');
          debugPrint('╚══════════════════════════════════════════════════════════════');
          Get.offAllNamed(AppRoutes.userDashBoard);
        } else {
          debugPrint('║ ➡️ User -> Location screen');
          debugPrint('╚══════════════════════════════════════════════════════════════');
          Get.offAllNamed(AppRoutes.location);
        }
      } else {
        debugPrint('║ ➡️ User profile incomplete -> Choose');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        Get.offAllNamed(AppRoutes.choose);
      }
    } else {
      debugPrint('║ ➡️ Unknown userType -> Login');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = (index * 0.8);
        final value = (1 + (0.3 * (1 +
            (Math.sin(_animation.value + offset)))));
        return Transform.scale(
          scale: value,
          child: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              "assets/images/logo.png",
              width: 240,
            ),
            const SizedBox(height: 12),

            // 3 dots animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
