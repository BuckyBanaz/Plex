import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant/app_colors.dart';

class SelectorField extends StatelessWidget {
  final String label;
  final String hint;
  final Rx<String?> value;
  final List<String> options;
  final bool isDropdown;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;

  const SelectorField({
    Key? key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    this.isDropdown = true,
    this.focusNode,
    this.nextFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* $label',
          style: Get.textTheme.bodyMedium!.copyWith(
            color: AppColors.textColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        if (isDropdown)
          Obx(
                () => DropdownButtonFormField<String>(
              focusNode: focusNode,
              value: value.value,
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option.tr, style: const TextStyle(color: Colors.black)),
                ),
              )
                  .toList(),
              onChanged: (String? newValue) {
                value.value = newValue;
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                }
              },
              style: Get.textTheme.bodyMedium!.copyWith(color: Colors.black),
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                hintText: hint,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (val) => val == null ? 'Required field'.tr : null,
            ),
          )
        else
          Obx(
                () => FormField<String>(
              initialValue: value.value,
              builder: (fieldState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((option) {
                        final bool selected = value.value == option;
                        return ChoiceChip(
                          label: Text(option.tr),
                          selected: selected,
                          onSelected: (sel) {
                            if (sel) {
                              value.value = option;
                              fieldState.didChange(option);
                              if (nextFocusNode != null) {
                                FocusScope.of(context).requestFocus(nextFocusNode);
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }).toList(),
                    ),
                    if (fieldState.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 4),
                        child: Text(
                          fieldState.errorText ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
              validator: (v) => v == null ? 'Required field'.tr : null,
            ),
          ),
      ],
    );
  }
}