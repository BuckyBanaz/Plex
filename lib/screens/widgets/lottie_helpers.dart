import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchingLottie extends StatefulWidget {
  final double speed; // animation speed multiplier
  final String assetPath; // allow custom lottie
  final double size; // optional size control

  const SearchingLottie({
    super.key,
    this.speed = 1.0,
    this.assetPath = "assets/lottie/tracking_animation.json",
    this.size = 200,
  });

  @override
  State<SearchingLottie> createState() => _SearchingLottieState();
}

class _SearchingLottieState extends State<SearchingLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Lottie.asset(
        widget.assetPath,
        controller: _controller,
        onLoaded: (composition) {
          // ✅ Convert to milliseconds and divide by speed properly
          final int newDurationMs =
          (composition.duration.inMilliseconds / widget.speed).round();

          _controller
            ..duration = Duration(milliseconds: newDurationMs)
            ..repeat();
        },
      ),
    );
  }
}
