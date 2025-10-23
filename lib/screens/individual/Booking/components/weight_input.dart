import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constant/app_colors.dart';
import '../../../../modules/contollers/booking/booking_controller.dart';

class WeightInput extends StatelessWidget {
  const WeightInput({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();

    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  focusedBorder:InputBorder.none
                ),
                onChanged: (value) {
                  controller.setWeight(double.tryParse(value) ?? 0.0);
                },
              ),
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedWeightUnit.value,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: <String>['Kg', 'Lb', 'g']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.setWeightUnit(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}