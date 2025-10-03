import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Bottom Snack bar
Future<void> showToast({required String message}) async {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}
