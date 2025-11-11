// driver_kyc_app_no_outer_obx.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constant/app_colors.dart';

class DriverKycController extends GetxController {
  final step = 0.obs;
  final pickedImage = Rxn<File>();
  final licenseNumber = ''.obs;

  bool get canProceed => pickedImage.value != null && licenseNumber.value.trim().isNotEmpty;

  final ImagePicker _picker = ImagePicker();

  Future pickImageFromGallery() async {
    final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) pickedImage.value = File(xfile.path);
  }

  Future captureImage() async {
    final XFile? xfile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (xfile != null) pickedImage.value = File(xfile.path);
  }

  void next() {
    if (step.value < 2) {
      step.value++;
      pickedImage.value = null;
      licenseNumber.value = '';
    } else {
      Get.snackbar('Submitted', 'KYC submitted successfully');
    }
  }

  void previous() {
    if (step.value > 0) step.value--;
  }
}

class DriverKycFlow extends StatelessWidget {
  DriverKycFlow({Key? key}) : super(key: key);
  final DriverKycController c = Get.put(DriverKycController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 18.0,vertical: 18),
            // <-- OUTER Obx REMOVED here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // only this small widget listens to step
                Obx(() => _ProgressIndicator(step: c.step.value)),
                SizedBox(height: 100),

                Text(
                  _titleForStep(c.step.value),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Upload a legible picture of your ${_docNameForStep(c.step.value)} to verify it',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                SizedBox(height: 30),

                // upload area: only listens to pickedImage
                Center(
                  child: GestureDetector(
                    onTap: () => _showImageOptions(context, c),
                    child: Obx(() {
                      final file = c.pickedImage.value;
                      return Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: 200),
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Color(0xFFF6A623), width: 3),
                        ),
                        child: file == null
                            ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 44, color: Color(0xFFF6A623)),
                            SizedBox(height: 10),
                            Text('Choose a image or Capture image', style: TextStyle(color: Colors.black54)),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(file, height: 120, fit: BoxFit.cover),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: 30),
                Text('${_labelForStep(c.step.value)}', style: TextStyle(fontSize: 12, color: Colors.black87)),
                SizedBox(height: 8),

                // TextField does not need Obx — onChanged updates the Rx
                TextField(
                  decoration: InputDecoration(
                    hintText: '3232 3456 3456',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF6A623)),

                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColors.primary!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                    ),
                  ),
                  onChanged: (v) => c.licenseNumber.value = v,
                ),

                SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      // Button only listens to canProceed
                      child: Obx(() => ElevatedButton(
                        onPressed: c.canProceed ? c.next : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Text('Next', style: TextStyle(fontSize: 16)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF6A623),
                          disabledBackgroundColor: Color(0xFFFFE0B8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleForStep(int s) {
    switch (s) {
      case 0:
        return "Let's Verify your Driver license";
      case 1:
        return "Let's Verify your ID Card";
      case 2:
        return "Let's Verify your Vehicle RC";
      default:
        return "Let's Verify";
    }
  }

  String _docNameForStep(int s) {
    switch (s) {
      case 0:
        return 'driver license';
      case 1:
        return 'ID card';
      case 2:
        return 'Vehicle RC';
      default:
        return 'document';
    }
  }

  String _labelForStep(int s) {
    switch (s) {
      case 0:
        return 'License Number';
      case 1:
        return 'ID Card Number';
      case 2:
        return 'Vehicle Number';
      default:
        return 'Number';
    }
  }

  void _showImageOptions(BuildContext context, DriverKycController c) {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                c.pickImageFromGallery();
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Capture image'),
              onTap: () {
                c.captureImage();
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Cancel'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF27324A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back, color: Colors.white),
          SizedBox(width: 4),
          Expanded(child: SizedBox()),
          Icon(Icons.signal_cellular_alt, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Icon(Icons.battery_full, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int step;
  const _ProgressIndicator({Key? key, required this.step}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color active = Color(0xFFF6A623);

    Widget circle(bool filled, String label) => Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: filled ? active : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: filled ? Colors.white : active, fontSize: 12)),
      ),
    );

    Widget line(bool activeLine) => Expanded(
      child: Container(
        height: 3,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: activeLine ? active : active.withOpacity(0.25),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    return Row(
      children: [
        circle(step >= 0, '✓'),
        line(step >= 1),
        circle(step >= 1, '2'),
        line(step >= 2),
        circle(step >= 2, '3'),
      ],
    );
  }
}
