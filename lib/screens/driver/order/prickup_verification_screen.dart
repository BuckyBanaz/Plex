import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/driver/order/pickup_confirm_screen.dart';

class PickupVerificationScreen extends StatefulWidget {
  const PickupVerificationScreen({super.key});

  @override
  State<PickupVerificationScreen> createState() =>
      _PickupVerificationScreenState();
}

class _PickupVerificationScreenState extends State<PickupVerificationScreen> {
  final int otpLength = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(otpLength, (_) => TextEditingController(), growable: false);
    _focusNodes = List.generate(otpLength, (_) => FocusNode(), growable: false);

     for (var ctrl in _controllers) {
      ctrl.addListener(_onAnyChange);
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.removeListener(_onAnyChange);
      ctrl.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onAnyChange() {
    setState(() {});
  }

  String get _currentOtp =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete =>
      _controllers.every((c) => c.text.isNotEmpty && c.text.length == 1);

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\s+'), '').split('');
      for (int i = 0; i < otpLength; i++) {
        if (i < chars.length) {
          _controllers[i].text = chars[i];
        } else {
          _controllers[i].clear();
        }
      }
      final nextIndex = (chars.length >= otpLength) ? otpLength - 1 : chars.length;
      _focusNodes[nextIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value[0];
      _controllers[index].selection = TextSelection.collapsed(offset: 1);
      if (index + 1 < otpLength) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKey(RawKeyEvent raw, int index) {
    if (raw is RawKeyDownEvent &&
        raw.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty) {
        if (index - 1 >= 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
        }
      } else {
        // clear current
        _controllers[index].clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Illustration (your svg)
              SvgPicture.asset(
                "assets/images/pickup_con.svg",
                height: 220,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              /// Title
              Text(
                "Pickup Verification",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              /// Subtitle
              const Text(
                "Enter the OTP provided by the customer to begin the pickup.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              /// OTP Fields (4)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  otpLength,
                      (index) => SizedBox(
                    width: 60,
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (raw) => _onKey(raw, index),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.black26,
                                width: 1.4,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.black26,
                                width: 1.4,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.6,
                              ),
                            ),
                          ),
                          onChanged: (value) => _onChanged(value, index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// Pick Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isComplete
                        ? AppColors.primary
                        : AppColors.primarySwatch.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isComplete
                      ? () {
                    // Use the OTP:
                    final otp = _currentOtp;
                    Get.to(PickupConfirmedScreen());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('OTP entered: $otp')),
                    );
                  }
                      : null,
                  child: Text(
                    "Pick up",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
