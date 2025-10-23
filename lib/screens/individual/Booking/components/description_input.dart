import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../../modules/contollers/booking/booking_controller.dart';

class DescriptionInput extends StatelessWidget {
  const DescriptionInput({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.primary),
      ),
      child: TextField(
        maxLines: 5, // Description ke liye multiple lines
        decoration: const InputDecoration(
          hintText: 'Enter description here...',
          border: InputBorder.none,
          focusedBorder:InputBorder.none,

          contentPadding: EdgeInsets.all(16.0),
        ),
        onChanged: (value) {
          controller.setDescription(value);
        },
      ),
    );
  }
}