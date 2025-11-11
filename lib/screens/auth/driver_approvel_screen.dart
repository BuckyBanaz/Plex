import 'package:flutter/material.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';

import '../../constant/app_colors.dart';




enum DocStatus { approved, pending, rejected }

class DriverApprovalScreen extends StatelessWidget {
  const DriverApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
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
                    decoration: const BoxDecoration(
                      color: Color(0x1AF5A623),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: size.width * 0.22,
                        height: size.width * 0.22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 48, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Approval Awaiting',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Your documents and vehicle details have submitted',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 100),

                  // Tiles
                  const DocumentTile(
                    title: 'Driver License',
                    status: DocStatus.approved,
                  ),

                  const SizedBox(height: 14),

                  const DocumentTile(
                    title: 'ID Card',
                    status: DocStatus.rejected,
                    showRetryNote: true,
                  ),

                  const SizedBox(height: 14),

                  const DocumentTile(
                    title: 'Vehicle RC',
                    status: DocStatus.rejected,
                    showRetryNote: true,
                  ),

                  const SizedBox(height: 22),
                  const Spacer(),
                  const Text(
                    'You will your notified once your verification complete.\nThis may take up to 24 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 10),


                  CustomButton(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      onTap: (){}, widget: Center(
                    child: Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),

                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 48,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.primary,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //     ),
                  //     onPressed: () {},
                  //     child: const Text(
                  //       'Refresh',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                   SizedBox(height: 20),
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

  const DocumentTile({
    super.key,
    required this.title,
    required this.status,
    this.showRetryNote = false,
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
        return AppColors.primary;
      case DocStatus.pending:
        return AppColors.primary;
      case DocStatus.rejected:
        return AppColors.primary;
    }
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
            border: Border.all(color: AppColors.primary, width: 1.6),
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconForStatus(), size: 18, color: _iconColor()),
              ),
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
                onTap: () {},
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
