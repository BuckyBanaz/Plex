// Helper method for password validation
import 'package:get/get.dart';

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Required field'.tr;
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters'.tr;
  }
  return null;
}

// Helper method for email validation
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Required field'.tr;
  }
  if (!GetUtils.isEmail(value)) {
    return 'Enter a valid email address'.tr;
  }
  return null;
}
