import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../constant/app_colors.dart';

import 'driver_job_complete.dart';

class DeliveryVerificationScreen extends StatefulWidget {
  const DeliveryVerificationScreen({super.key});

  @override
  State<DeliveryVerificationScreen> createState() =>
      _DeliveryVerificationScreenState();
}

class _DeliveryVerificationScreenState
    extends State<DeliveryVerificationScreen> {
  final int otpLength = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      otpLength,
      (_) => TextEditingController(),
      growable: false,
    );
    _focusNodes = List.generate(otpLength, (_) => FocusNode(), growable: false);

    for (var c in _controllers) {
      c.addListener(_onAnyChange);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.removeListener(_onAnyChange);
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onAnyChange() => setState(() {});

  String get _currentOtp => _controllers.map((c) => c.text).join();

  bool get _isComplete =>
      _controllers.every((c) => c.text.isNotEmpty && c.text.length == 1);

  void _onChanged(String value, int index) {
    // Handle paste or multi-char input
    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\s+'), '').split('');
      for (int i = 0; i < otpLength; i++) {
        if (i < chars.length) {
          _controllers[i].text = chars[i];
        } else {
          _controllers[i].clear();
        }
      }
      final nextIndex = (chars.length >= otpLength)
          ? otpLength - 1
          : chars.length;
      _focusNodes[nextIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value[0];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
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
              const SizedBox(height: 32),

              // Illustration (use SVG asset; for quick local preview you can use the uploaded PNG path)
              SvgPicture.asset(
                "assets/images/droff_con.svg",
                height: 220,
                fit: BoxFit.contain,
                // If you want to preview using uploaded PNG during development, replace above with:
                // Image.asset('/mnt/data/f167caf5-879b-4f54-990a-9fef507a9bf1.png', height: 220),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                "Delivery Verification",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                "Enter the OTP shared by the customer to confirm the delivery.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: Colors.black54),
              ),

              const SizedBox(height: 28),

              // OTP fields
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

                          onChanged: (v) => _onChanged(v, index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Delivered button
              SizedBox(
                width: double.infinity,
                height: 52,
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
                          final otp = _currentOtp;
                          Get.to(
                            DriverJobCompleteScreen(
                              amount: 199,
                              paymentMethod: "code",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('OTP entered: $otp')),
                          );
                        }
                      : null,
                  child: const Text(
                    "Delivered",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
