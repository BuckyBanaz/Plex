import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';
import 'package:plex_user/services/domain/service/app/app_service_imports.dart';

import '../../constant/app_colors.dart';

enum DocStatus { approved, pending, rejected }

class DriverApprovalScreen extends StatefulWidget {
  const DriverApprovalScreen({super.key});

  @override
  State<DriverApprovalScreen> createState() => _DriverApprovalScreenState();
}

class _DriverApprovalScreenState extends State<DriverApprovalScreen> {
  final DatabaseService db = Get.find<DatabaseService>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  bool _isLoading = true;
  String _overallStatus = 'pending';
  String? _rejectionReason;

  // Document statuses
  DocStatus _licenseStatus = DocStatus.pending;
  DocStatus _idCardStatus = DocStatus.pending;
  DocStatus _vehicleStatus = DocStatus.pending;
  DocStatus _profileStatus = DocStatus.pending;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authRepo.getDriverStatus();

      if (response['success'] == true) {
        final data = response['data'];

        // Overall KYC status
        final kycStatus = data['kycStatus'] ?? 'not_submitted';
        _overallStatus = kycStatus;
        
        debugPrint('Approval screen - Backend kycStatus: $kycStatus');

        // If KYC not submitted, redirect to KYC screen
        if (kycStatus == 'not_submitted' || kycStatus.isEmpty) {
          debugPrint('KYC not submitted - redirecting to KYC screen');
          db.putKycDone(false);
          Get.offAllNamed(AppRoutes.kyc);
          return;
        }

        // Individual document statuses from KYC data
        final kycData = data['kyc'];
        if (kycData != null) {
          _licenseStatus = _parseDocStatus(kycData['licenseVerified']);
          _idCardStatus = _parseDocStatus(kycData['idVerified']);
          _profileStatus = _parseDocStatus(kycData['verifiedStatus']);
        }

        // Vehicle status
        final vehicleData = data['vehicle'];
        if (vehicleData != null) {
          _vehicleStatus = _parseDocStatus(vehicleData['verificationStatus']);
        }

        // Rejection reason if any
        _rejectionReason = kycData?['rejectionReason'] ?? data['rejectionReason'];

        // Check if verified - navigate to dashboard
        if (kycStatus == 'verified') {
          db.putKycDone(true);
          CustomSnackbar.success(
            'Your account has been verified. Welcome!',
            title: 'Approved!',
          );
          // Navigate to location/dashboard
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAllNamed(AppRoutes.location);
          return;
        }
      } else {
        debugPrint('Failed to fetch status: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error fetching driver status: $e');
    }

    setState(() => _isLoading = false);
  }

  DocStatus _parseDocStatus(dynamic status) {
    if (status == null) return DocStatus.pending;

    final statusStr = status.toString().toLowerCase();
    if (statusStr == 'verified' || statusStr == 'approved' || statusStr == 'true') {
      return DocStatus.approved;
    } else if (statusStr == 'rejected' || statusStr == 'failed') {
      return DocStatus.rejected;
    }
    return DocStatus.pending;
  }

  String _getStatusTitle() {
    switch (_overallStatus) {
      case 'verified':
        return 'Approved!';
      case 'rejected':
        return 'Application Rejected';
      default:
        return 'Approval Awaiting';
    }
  }

  String _getStatusSubtitle() {
    switch (_overallStatus) {
      case 'verified':
        return 'Congratulations! Your documents have been verified.';
      case 'rejected':
        return _rejectionReason ?? 'Your application was rejected. Please resubmit.';
      default:
        return 'Your documents and vehicle details have been submitted';
    }
  }

  IconData _getHeaderIcon() {
    switch (_overallStatus) {
      case 'verified':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.hourglass_bottom;
    }
  }

  Color _getHeaderColor() {
    switch (_overallStatus) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  void _handleRetry() {
    // Navigate back to KYC screen to resubmit
    db.putKycDone(false);
    Get.offAllNamed(AppRoutes.kyc);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 28),
                        // Top round icon
                        Container(
                          width: size.width * 0.32,
                          height: size.width * 0.32,
                          decoration: BoxDecoration(
                            color: _getHeaderColor().withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: size.width * 0.22,
                              height: size.width * 0.22,
                              decoration: BoxDecoration(
                                color: _getHeaderColor(),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getHeaderIcon(), size: 48, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          _getStatusTitle(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _overallStatus == 'rejected' ? Colors.red : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          _getStatusSubtitle(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Document Tiles
                        DocumentTile(
                          title: 'Driver License',
                          status: _licenseStatus,
                          showRetryNote: _licenseStatus == DocStatus.rejected,
                          onRetry: _handleRetry,
                        ),

                        const SizedBox(height: 14),

                        DocumentTile(
                          title: 'ID Card',
                          status: _idCardStatus,
                          showRetryNote: _idCardStatus == DocStatus.rejected,
                          onRetry: _handleRetry,
                        ),

                        const SizedBox(height: 14),

                        DocumentTile(
                          title: 'Vehicle RC',
                          status: _vehicleStatus,
                          showRetryNote: _vehicleStatus == DocStatus.rejected,
                          onRetry: _handleRetry,
                        ),

                        const SizedBox(height: 14),

                        DocumentTile(
                          title: 'Profile Image',
                          status: _profileStatus,
                          showRetryNote: _profileStatus == DocStatus.rejected,
                          onRetry: _handleRetry,
                        ),

                        const SizedBox(height: 22),
                        const Spacer(),

                        if (_overallStatus == 'rejected') ...[
                          const Text(
                            'Please resubmit your documents to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            onTap: _handleRetry,
                            widget: const Center(
                              child: Text(
                                'Resubmit KYC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'You will be notified once your verification is complete.\nThis may take up to 24 hours.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            onTap: _fetchStatus,
                            widget: const Center(
                              child: Text(
                                'Refresh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class DocumentTile extends StatelessWidget {
  final String title;
  final DocStatus status;
  final bool showRetryNote;
  final VoidCallback? onRetry;

  const DocumentTile({
    super.key,
    required this.title,
    required this.status,
    this.showRetryNote = false,
    this.onRetry,
  });

  IconData _iconForStatus() {
    switch (status) {
      case DocStatus.approved:
        return Icons.check_circle;
      case DocStatus.pending:
        return Icons.hourglass_bottom_rounded;
      case DocStatus.rejected:
        return Icons.error_outline;
    }
  }

  Color _iconColor() {
    switch (status) {
      case DocStatus.approved:
        return Colors.green;
      case DocStatus.pending:
        return AppColors.primary;
      case DocStatus.rejected:
        return Colors.red;
    }
  }

  Widget _statusIcon() {
    if (status == DocStatus.pending) {
      return RotatingDottedCircle(
        size: 36,
        dotColor: AppColors.primary,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.4),
          ),
          child: Icon(
            _iconForStatus(),
            size: 16,
            color: _iconColor(),
          ),
        ),
      );
    }

    // Approved / Rejected — static icon
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: _iconColor(), width: 1.4),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForStatus(),
        size: 18,
        color: _iconColor(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _iconColor(), width: 1.6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _statusIcon(),
            ],
          ),
        ),
        if (showRetryNote) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Verification Not Approved – ',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
              GestureDetector(
                onTap: onRetry,
                child: const Text(
                  'Retry Verification',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class RotatingDottedCircle extends StatefulWidget {
  final double size;
  final Color dotColor;
  final Widget child;

  const RotatingDottedCircle({
    super.key,
    required this.size,
    required this.dotColor,
    required this.child,
  });

  @override
  State<RotatingDottedCircle> createState() => _RotatingDottedCircleState();
}

class _RotatingDottedCircleState extends State<RotatingDottedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _DottedCirclePainter(color: widget.dotColor),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;

  _DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double dotRadius = 5;
    double angle = 0 * Math.pi / 179;

    Offset offset = Offset(
      radius + radius * 0.70 * Math.cos(angle),
      radius + radius * 0.70 * Math.sin(angle),
    );

    canvas.drawCircle(offset, dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
