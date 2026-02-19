// lib/screens/admin/admin_kyc_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constant/app_colors.dart';
import '../../services/domain/repository/admin/admin_repository.dart';
import '../widgets/custom_snackbar.dart';

class AdminKycDetailScreen extends StatefulWidget {
  final KycApplication application;

  const AdminKycDetailScreen({super.key, required this.application});

  @override
  State<AdminKycDetailScreen> createState() => _AdminKycDetailScreenState();
}

class _AdminKycDetailScreenState extends State<AdminKycDetailScreen> {
  final AdminRepository _adminRepo = Get.find<AdminRepository>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final docs = app.documents;
    final vehicle = app.vehicle;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          "KYC #${app.kycId}",
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                _statusCard(app),
                const SizedBox(height: 16),

                // Driver Info
                _sectionCard(
                  title: 'Driver Information',
                  icon: Icons.person,
                  children: [
                    _infoRow('Driver ID', '#${app.driverId}'),
                    if (app.driver?.name != null)
                      _infoRow('Name', app.driver!.name!),
                    if (app.driver?.email != null)
                      _infoRow('Email', app.driver!.email!),
                    if (app.driver?.phone != null)
                      _infoRow('Phone', app.driver!.phone!),
                  ],
                ),
                const SizedBox(height: 16),

                // ID Proof Section
                _sectionCard(
                  title: 'ID Proof',
                  icon: Icons.credit_card,
                  children: [
                    if (docs?.idProofType != null)
                      _infoRow('ID Type', _formatIdType(docs!.idProofType!)),
                    if (docs?.mainIdNumber != null)
                      _infoRow('ID Number', docs!.mainIdNumber!),
                    const SizedBox(height: 12),
                    if (docs?.mainIdImage != null)
                      _imageSection('ID Document', docs!.mainIdImage!),
                  ],
                ),
                const SizedBox(height: 16),

                // Profile Photo
                _sectionCard(
                  title: 'Profile Photo',
                  icon: Icons.face,
                  children: [
                    if (docs?.profileImage != null)
                      _imageSection('Profile', docs!.profileImage!, isProfile: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Vehicle Info
                if (vehicle != null)
                  _sectionCard(
                    title: 'Vehicle Information',
                    icon: Icons.directions_car,
                    children: [
                      if (vehicle.vehicleType != null)
                        _infoRow('Vehicle Type', vehicle.vehicleType!),
                      if (vehicle.licensePlate != null)
                        _infoRow('License Plate', vehicle.licensePlate!),
                      if (vehicle.vehicleMake != null)
                        _infoRow('Make', vehicle.vehicleMake!),
                      if (vehicle.vehicleModel != null)
                        _infoRow('Model', vehicle.vehicleModel!),
                      if (vehicle.fuelType != null)
                        _infoRow('Fuel Type', vehicle.fuelType!),
                      if (vehicle.vehicleAge != null)
                        _infoRow('Age', '${vehicle.vehicleAge} years'),
                      const SizedBox(height: 12),
                      if (vehicle.vehicleImageUrl != null)
                        _imageSection('Vehicle Photo', vehicle.vehicleImageUrl!),
                    ],
                  ),

                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),

          // Bottom action buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _rejectKyc,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _approveKyc,
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusCard(KycApplication app) {
    Color color;
    String label;
    IconData icon;

    switch (app.status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending Review';
        icon = Icons.hourglass_bottom;
        break;
      case 'awaiting_approval':
        color = Colors.purple;
        label = 'Awaiting Approval';
        icon = Icons.pending_actions;
        break;
      case 'verified':
        color = Colors.green;
        label = 'Verified';
        icon = Icons.verified;
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = app.status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (app.submittedAt != null)
                Text(
                  'Submitted: ${_formatDate(app.submittedAt!)}',
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageSection(String label, String url, {bool isProfile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showFullImage(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isProfile ? 100 : 12),
            child: CachedNetworkImage(
              imageUrl: url,
              width: isProfile ? 120 : double.infinity,
              height: isProfile ? 120 : 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.error),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to view full image',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }

  void _showFullImage(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatIdType(String type) {
    switch (type) {
      case 'drivers_license':
        return 'Driver\'s License';
      case 'passport':
        return 'Passport';
      case 'national_id':
        return 'National ID Card';
      case 'residence_permit':
        return 'Residence Permit';
      case 'government_id':
        return 'Government ID';
      default:
        return type;
    }
  }

  Future<void> _approveKyc() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Approve KYC'),
        content: const Text('Are you sure you want to approve this KYC application?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final result = await _adminRepo.approveKyc(widget.application.kycId);
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        CustomSnackbar.success('KYC approved successfully');
        Get.back(result: true);
      } else {
        CustomSnackbar.error(result['message'] ?? 'Failed to approve');
      }
    }
  }

  Future<void> _rejectKyc() async {
    final reasonController = TextEditingController();

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject KYC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'e.g., Blurry document, Invalid ID',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                CustomSnackbar.error('Please enter rejection reason');
                return;
              }
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      final result = await _adminRepo.rejectKyc(
        widget.application.kycId,
        reason: reasonController.text.trim(),
      );
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        CustomSnackbar.warning('KYC rejected');
        Get.back(result: true);
      } else {
        CustomSnackbar.error(result['message'] ?? 'Failed to reject');
      }
    }
  }
}
