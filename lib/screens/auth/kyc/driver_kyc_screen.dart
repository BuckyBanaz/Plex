import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plex_user/routes/appRoutes.dart';
import '../../../constant/app_colors.dart';
import '../../../modules/controllers/auth/kyc_controller.dart';


class DriverKycFlow extends StatelessWidget {
  DriverKycFlow({super.key});

  final DriverKycController c = Get.put(DriverKycController());
  final TextEditingController textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Sync text controller when value changes
          if (c.step.value != 3) {
            textCtrl.text = c.inputNumber.value;
          }

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                _ProgressIndicator(step: c.step.value),
                const SizedBox(height: 100),

                Text(
                  _titleForStep(c.step.value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  "Upload your ${_docNameForStep(c.step.value)}",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // Upload Image Box
                Center(
                  child: GestureDetector(
                    onTap: () => _showOptions(context),
                    child: _uploadBox(
                      isCircular: c.step.value == 3,
                      image: c.pickedImage.value,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                if (c.step.value != 3)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelForStep(c.step.value),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: textCtrl,
                        onChanged: (v) => c.inputNumber.value = v,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: c.canProceed ? c.nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  AppColors.primary,
                    disabledBackgroundColor: AppColors.primarySwatch.shade100,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _uploadBox({required bool isCircular, required File? image}) {
    if (isCircular) {
      return DottedBorder(
        options: CircularDottedBorderOptions(
          // borderType: BorderType.Circle,
          color: AppColors.primary,
          dashPattern: const [6, 6],
          strokeWidth: 3,
        ),

        child: Container(
          width: 160,
          height: 160,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: image == null
              ? _uploadIcon()
              : ClipOval(child: Image.file(image, fit: BoxFit.cover)),
        ),
      );
    }

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        // borderType: BorderType.RRect,
        radius: const Radius.circular(18),
        color:AppColors.primary,
        dashPattern: const [6, 6],
        strokeWidth: 3,

        // radius: radius
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minHeight: 200),
        child: image == null
            ? _uploadIcon()
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image, height: 160, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _uploadIcon() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.cloud_upload_outlined, size: 44, color: Colors.orange),
      SizedBox(height: 10),
      Text("Upload Image", style: TextStyle(color: Colors.black54)),
    ],
  );

  void _showOptions(BuildContext context) {
    Get.bottomSheet(
      Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Choose from Gallery"),
            onTap: () {
              c.pickImageFromGallery();
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Capture Image"),
            onTap: () {
              c.captureImage();
              Get.back();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

// ---------------- PROGRESS BAR ------------------

class _ProgressIndicator extends StatelessWidget {
  final int step;
  const _ProgressIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    Color active = const Color(0xFFF6A623);

    Widget node(int index) {
      bool done = step > index;
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: done ? active : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active),
        ),
        child: Center(
          child: Text(
            done ? "✓" : "${index + 1}",
            style: TextStyle(color: done ? Colors.white : active),
          ),
        ),
      );
    }

    Widget line(int index) {
      return Expanded(
        child: Container(
          height: 3,
          color: step > index ? active : active.withOpacity(0.3),
        ),
      );
    }

    return Row(
      children: [node(0), line(0), node(1), line(1), node(2), line(2), node(3)],
    );
  }
}

// ---------------- TITLE HELPERS ------------------

String _titleForStep(int s) {
  return [
    "Let's Verify your Driver License",
    "Let's Verify your ID Card",
    "Let's Verify your Vehicle RC",
    "Let's Verify your Profile Picture",
  ][s];
}

String _docNameForStep(int s) {
  return ["Driver License", "ID Card", "Vehicle RC", "Profile Photo"][s];
}

String _labelForStep(int s) {
  return ["License Number", "ID Card Number", "Vehicle Number"][s];
}
