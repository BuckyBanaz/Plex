import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // optional: add intl in pubspec (if not available you can format manually)
import '../../../../constant/app_colors.dart';
import '../../../../modules/controllers/booking/booking_controller.dart';

class CollectTimeSelector extends StatelessWidget {
  const CollectTimeSelector({super.key});

  String _formatDateTime(DateTime dt) {
    // If you don't want to add intl package, you can use dt.toLocal().toString() or custom format
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dt.toLocal().toString().split('.').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();

    return Obx(() {
      return Column(
        children: [
          Row(
            children: [
              // Immediate Card
              Expanded(
                child: GestureDetector(
                  onTap: () => c.selectTime(0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.selectedTime.value == 0
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "immediate".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(
                              c.selectedTime.value == 0
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "collect_time_range".tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "delivery_to_receiver".tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Schedule Card
              Expanded(
                child: GestureDetector(
                  onTap: () => c.selectTime(1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.selectedTime.value == 1
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "schedule".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(
                              c.selectedTime.value == 1
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "choose_available_time".tr,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "plan_2_day_ahead".tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // If Schedule selected, show picker row
          if (c.selectedTime.value == 1) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // pick date
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(hours: 2)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary, // ✅ Main accent (selected date, buttons)
                                onPrimary: Colors.white, // ✅ Text color on selected date/button
                                onSurface: Colors.black87, // ✅ Default text color
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary, // ✅ "CANCEL"/"OK" buttons
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (date == null) return;

                      // pick time
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                secondary: AppColors.primary,
                                onSurface: Colors.black87,
                              ),
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor: Colors.white,
                                hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                                states.contains(MaterialState.selected)
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.grey.shade100),
                                hourMinuteTextColor: AppColors.primary,
                                dialBackgroundColor: AppColors.primary.withOpacity(0.1),
                                dialHandColor: AppColors.primary,
                                dialTextColor: MaterialStateColor.resolveWith((states) =>
                                states.contains(MaterialState.selected)
                                    ? Colors.white
                                    : Colors.black87),
                                entryModeIconColor: AppColors.primary,
                                dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                                states.contains(MaterialState.selected)
                                    ? AppColors.primary
                                    : Colors.grey.shade200),
                                dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                                states.contains(MaterialState.selected)
                                    ? Colors.white
                                    : Colors.black87),
                                helpTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (time == null) return;

                      final selected = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );

                      c.setScheduledDateTime(selected);
                      // optional: scroll or focus back
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text("choose_available_time".tr),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Show chosen datetime if any
            if (c.scheduledDateTime.value != null)
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pickup: ${_formatDateTime(c.scheduledDateTime.value!)}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => c.scheduledDateTime.value = null,
                    child: Text("change".tr),
                  ),
                ],
              ),
          ],
        ],
      );
    });
  }
}
