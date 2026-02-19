import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/constant/api_endpoint.dart';
import 'package:plex_user/screens/driver/order/driver_job_complete.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';
import '../../../common/Toast/toast.dart';

class DeliveryVerificationScreen extends StatefulWidget {
  final Map<String, dynamic>? shipment;
  
  const DeliveryVerificationScreen({super.key, this.shipment});

  @override
  State<DeliveryVerificationScreen> createState() =>
      _DeliveryVerificationScreenState();
}

class _DeliveryVerificationScreenState extends State<DeliveryVerificationScreen> {
  final int otpLength = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;
  bool _isResending = false;
  
  Map<String, dynamic> get _shipment => 
      widget.shipment ?? Get.arguments?['shipment'] ?? {};

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

  Future<void> _verifyOtp() async {
    if (!_isComplete || _isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final shipmentId = _shipment['id']?.toString() ?? '';
      final otp = _currentOtp;
      
      final dio = Dio();
      final db = Get.find<DatabaseService>();
      dio.options.headers['Authorization'] = 'Bearer ${db.accessToken}';
      
      final endpoint = ApiEndpoint.verifyDropoffOtp.replaceFirst(':id', shipmentId);
      final response = await dio.post(
        '${ApiEndpoint.baseUrl}$endpoint',
        data: {'otp': otp},
      );
      
      if (response.data['success'] == true) {
        showToast(message: 'Delivery completed successfully!');
        
        // Get data from API response (more reliable than passed shipment)
        final responseShipment = response.data['shipment'];
        
        // Get fare - prefer response data, fallback to passed shipment
        final fare = responseShipment?['estimatedCost'] ?? 
                     _shipment['estimatedCost'] ?? 
                     _shipment['pricing']?['amount'] ??
                     _shipment['pricing']?['estimatedCostINR'] ??
                     _shipment['amount'] ?? 0;
        
        // Get payment method - prefer response data, fallback to passed shipment
        final paymentMethod = responseShipment?['paymentMethod'] ??
                              _shipment['paymentMethod'] ?? 
                              _shipment['payment_method'] ??
                              _shipment['pricing']?['paymentMethod'] ??
                              'COD';
        
        debugPrint('╔══════════════════════════════════════════════════════════════');
        debugPrint('║ 💰 TRIP COMPLETED');
        debugPrint('║ Response Shipment: $responseShipment');
        debugPrint('║ Fare: $fare');
        debugPrint('║ Payment Method: $paymentMethod');
        debugPrint('║ Passed shipment paymentMethod: ${_shipment['paymentMethod']}');
        debugPrint('╚══════════════════════════════════════════════════════════════');
        
        Get.offAll(() => DriverJobCompleteScreen(
          amount: (fare is int) ? fare.toDouble() : (fare is double ? fare : double.tryParse(fare.toString()) ?? 0.0),
          paymentMethod: paymentMethod.toString().toUpperCase(),
        ));
      } else {
        showToast(message: response.data['message'] ?? 'Verification failed');
      }
    } catch (e) {
      debugPrint('OTP verification error: $e');
      String errorMsg = 'Verification failed';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      showToast(message: errorMsg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;
    
    setState(() => _isResending = true);
    
    try {
      final shipmentId = _shipment['id']?.toString() ?? '';
      
      final dio = Dio();
      final db = Get.find<DatabaseService>();
      dio.options.headers['Authorization'] = 'Bearer ${db.accessToken}';
      
      final endpoint = ApiEndpoint.resendShipmentOtp.replaceFirst(':id', shipmentId);
      final response = await dio.post(
        '${ApiEndpoint.baseUrl}$endpoint',
        data: {'otpType': 'dropoff'},
      );
      
      if (response.data['success'] == true) {
        showToast(message: 'OTP notification sent to customer');
      } else {
        showToast(message: response.data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      showToast(message: 'Failed to resend OTP');
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Illustration
              SvgPicture.asset(
                "assets/images/droff_con.svg",
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                "Delivery Verification",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                "Enter the OTP shared by the customer to confirm the delivery.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  otpLength,
                  (index) => SizedBox(
                    width: 60,
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (raw) => _onKey(raw, index),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          onChanged: (v) => _onChanged(v, index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Resend OTP
              TextButton(
                onPressed: _isResending ? null : _resendOtp,
                child: _isResending 
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      "Resend OTP to Customer",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),

              const Spacer(),

              // Delivered button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isComplete && !_isLoading
                        ? AppColors.primary
                        : AppColors.primarySwatch.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isComplete && !_isLoading ? _verifyOtp : null,
                  child: _isLoading
                      ? SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Verify & Complete Delivery",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
