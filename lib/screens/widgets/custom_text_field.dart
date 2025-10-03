import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/app_colors.dart';

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
          '* ${widget.label}',
          style: Get.textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimary.withOpacity(0.8),
            fontSize: 14,
          ),
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
              borderRadius: BorderRadius.circular(8),
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
                  (value) => (value == null || value.isEmpty) ? 'Required field'.tr : null,
          onFieldSubmitted: _handleSubmitted,
        ),
      ],
    );
  }
}
