import 'package:flutter/material.dart';

import '../dialog/app_dialog.dart';

class Loading extends StatelessWidget {
  final String? title;

  Loading({this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title!, style: TextStyle(fontSize: 18)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppDialog.loader(),
          ),
        ],
      ),
    );
  }
}
