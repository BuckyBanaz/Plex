import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../alert/alert.dart';
import '../loading/loading.dart';

class AppDialog {
  static Future<T?> dialog<T>({required Widget Function(BuildContext, Animation<double>, Animation<double>) pageBuilder, required barrierDismissible}) async {
    return await Get.generalDialog(
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black38,
      pageBuilder: pageBuilder,
    );
  }

  static Future<bool> alert<bool>({required Widget title, Widget? content, String? confirmText, String? denyText, bool? dismissible}) async {
    return await dialog(
      pageBuilder: (context, animation1, animation2) => Alert(
        title: title,
        content: content,
        confirmText: confirmText,
        denyText: denyText,
      ),
      barrierDismissible: dismissible ?? true,
    ) ?? false;
  }

  static Future<T?> loading<T>({String? title}) async {
    return await dialog(
      pageBuilder: (context, animation1, animation2) => Loading(
        title: title,
      ),
      barrierDismissible: false,
    );
  }

  static Widget loader() {
    return Center(
      child: SpinKitCircle(
        color: Colors.blue, // Specify a default color
        size: 40.0,
      ),
    );
  }
}
