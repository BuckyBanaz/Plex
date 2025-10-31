import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/app_colors.dart';
import '../../modules/controllers/booking/booking_controller.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback? onPrevious;
  final VoidCallback? onSubmitted; // called for done action or custom handling
  final bool autofocus;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
    this.isPassword = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.onPrevious,
    this.onSubmitted,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  void _handleSubmitted(String value) {
    if (widget.textInputAction == TextInputAction.next) {
      if (widget.nextFocusNode != null) {
        widget.nextFocusNode!.requestFocus();
      } else {
        FocusScope.of(context).nextFocus();
      }
    } else if (widget.textInputAction == TextInputAction.previous) {
      if (widget.onPrevious != null) {
        widget.onPrevious!();
      } else {
        FocusScope.of(context).previousFocus();
      }
    } else if (widget.textInputAction == TextInputAction.done ||
        widget.textInputAction == TextInputAction.go ||
        widget.textInputAction == TextInputAction.send ||
        widget.textInputAction == TextInputAction.search) {
      if (widget.onSubmitted != null) widget.onSubmitted!();
      FocusScope.of(context).unfocus();
    } else {
      // fallback: call onSubmitted if provided
      if (widget.onSubmitted != null) widget.onSubmitted!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* ${widget.label}'.tr,
          style: Get.textTheme.bodyMedium!.copyWith(
            color: AppColors.textColor.withOpacity(0.8),
            fontSize: 14,

          ),
          textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          obscureText: _obscure,
          style: TextStyle(color: Colors.black),

          decoration: InputDecoration(
            hintText: widget.hint,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
              ),
            )
                : null,
          ),
          validator: widget.validator ??
                  (value) => (value == null || value.isEmpty) ? 'required_field'.tr : null,
          onFieldSubmitted: _handleSubmitted,
        ),
      ],
    );
  }
}






typedef CountryChangedCallback = void Function(String countryCode, String countryIso);



class PhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final VoidCallback? onPrevious;
  final VoidCallback? onSubmitted;
  final bool autofocus;
  final String initialCountryIso; // 'IN' or 'SA'
  final CountryChangedCallback? onCountryChanged;
  final String? Function(String?)? validator;

  const PhoneTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.onPrevious,
    this.onSubmitted,
    this.autofocus = false,
    this.initialCountryIso = 'IN',
    this.onCountryChanged,
    this.validator,
  }) : super(key: key);

  @override
  _PhoneTextFieldState createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  final List<Map<String, String>> _countries = const [
    {"name": "India", "iso": "IN", "code": "+91", "flag": "🇮🇳"},
    {"name": "Saudi Arabia", "iso": "SA", "code": "+966", "flag": "🇸🇦"},
  ];

  final Map<String, int> _subscriberLength = {
    'IN': 10,
    'SA': 9,
  };

  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.firstWhere(
          (c) => c["iso"] == widget.initialCountryIso,
      orElse: () => _countries.first,
    );
  }

  void _handleSubmitted(String value) {
    if (widget.textInputAction == TextInputAction.next) {
      if (widget.nextFocusNode != null) {
        widget.nextFocusNode!.requestFocus();
      } else {
        FocusScope.of(context).nextFocus();
      }
    } else if (widget.textInputAction == TextInputAction.previous) {
      if (widget.onPrevious != null) {
        widget.onPrevious!();
      } else {
        FocusScope.of(context).previousFocus();
      }
    } else {
      widget.onSubmitted?.call();
      FocusScope.of(context).unfocus();
    }
  }


  /// Returns full E.164 number: +<countrycode><number>
  String getFullNumber() {
    final raw = widget.controller.text.trim();
    final code = _selectedCountry['code'] ?? '';
    final normalized = raw.replaceAll(RegExp(r'^\+|^0+|\D'), '');
    return '$code$normalized';
  }

  String? _validatePhone(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) return 'required_field'.tr;

    final selectedCode = _selectedCountry['code'] ?? '';
    final selectedIso = _selectedCountry['iso'] ?? '';

    String numericCountryCode(String cc) => cc.replaceFirst('+', '');

    if (input.startsWith('+')) {
      final match = RegExp(r'^\+(\d{1,3})(\d+)$').firstMatch(input);
      if (match == null) return 'enter_valid_phone'.tr;

      final enteredCode = match.group(1)!;
      final subscriber = match.group(2)!;

      if (enteredCode != numericCountryCode(selectedCode)) {
        return 'country_code_mismatch'.tr;
      }

      final expectedLen = _subscriberLength[selectedIso];
      if (expectedLen != null && subscriber.length != expectedLen) {
        return 'enter_valid_country_phone'.trParams({'country': _selectedCountry['name']!});
      }
      return null;
    }

    final cleaned = input.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^0+'), '');
    if (cleaned.isEmpty) return 'enter_valid_phone'.tr;

    final expectedLenLocal = _subscriberLength[selectedIso];
    if (expectedLenLocal != null && cleaned.length != expectedLenLocal) {
      return 'enter_valid_country_phone'.trParams({'country': _selectedCountry['name']!});
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (val) => widget.validator?.call(widget.controller.text) ?? _validatePhone(widget.controller.text),
      autovalidateMode: AutovalidateMode.disabled,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '* ${widget.label}'.tr,
              style: Get.textTheme.bodyMedium!.copyWith(
                color: AppColors.textColor.withOpacity(0.8),
                fontSize: 14,
              ),
              textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Country picker
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, String>>(
                      value: _selectedCountry,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      items: _countries.map((country) {
                        return DropdownMenuItem<Map<String, String>>(
                          value: country,
                          child: Row(
                            children: [
                              Text(country['flag'] ?? '', style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text('${country['code']}', style: const TextStyle(color: Colors.black)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCountry = value);
                        widget.onCountryChanged?.call(value['code'] ?? '', value['iso'] ?? '');
                        state.validate();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    keyboardType: TextInputType.phone,
                    focusNode: widget.focusNode,
                    textInputAction: widget.textInputAction,
                    autofocus: widget.autofocus,
                    style: const TextStyle(color: Colors.black),
                    textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? '512345678'.tr,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onFieldSubmitted: _handleSubmitted, // ✅ important
                    onChanged: (_) => state.didChange(widget.controller.text),
                  ),
                ),

              ],
            ),
            if (state.hasError) ...[
              const SizedBox(height: 5),
              Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              ),
            ],
          ],
        );
      },
    );
  }
}


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
                decoration:  InputDecoration(
                    hintText: '0'.tr,
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
        maxLines: 5,
        decoration:  InputDecoration(
          hintText: 'enter_description'.tr,
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



class SimpleTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? hint;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final FocusNode? nextFocusNode;
  final VoidCallback? onPrevious;
  final VoidCallback? onSubmitted; // called for done action or custom handling

  const SimpleTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text, this.hint, this.focusNode, this.nextFocusNode, this.onPrevious, this.onSubmitted, required this.textInputAction, this.validator,
  });

  @override
  State<SimpleTextField> createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {


  void _handleSubmitted(String value) {
    if (widget.textInputAction == TextInputAction.next) {
      if (widget.nextFocusNode != null) {
        widget.nextFocusNode!.requestFocus();
      } else {
        FocusScope.of(context).nextFocus();
      }
    } else if (widget.textInputAction == TextInputAction.previous) {
      if (widget.onPrevious != null) {
        widget.onPrevious!();
      } else {
        FocusScope.of(context).previousFocus();
      }
    } else if (widget.textInputAction == TextInputAction.done ||
        widget.textInputAction == TextInputAction.go ||
        widget.textInputAction == TextInputAction.send ||
        widget.textInputAction == TextInputAction.search) {
      if (widget.onSubmitted != null) widget.onSubmitted!();
      FocusScope.of(context).unfocus();
    } else {
      // fallback: call onSubmitted if provided
      if (widget.onSubmitted != null) widget.onSubmitted!();
    }
  }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      focusNode: widget.focusNode,
      validator: widget.validator ??
              (value) => (value == null || value.isEmpty) ? 'required_field'.tr : null,
      onFieldSubmitted: _handleSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

