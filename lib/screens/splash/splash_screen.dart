import 'dart:async';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/app_colors.dart';
import '../../routes/appRoutes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 2 * 3.14).animate(_controller);

    // After 3 seconds -> go to Login
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.login);
    });
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
