//Sdk Dependancy

import 'package:flutter/material.dart';

//Package Dependancy
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';

import '../../constant/app_strings.dart';

//Internal Dependancy



class Alert extends StatelessWidget {
  final Widget title;
  final Widget? content;
  final String? confirmText;
  final String? denyText;
  const Alert({Key? key, required this.title,  this.content, this.confirmText, this.denyText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondary,
      title: title,
      content: content,
     //titleTextStyle: theme.textTheme.titleLarge,
      actions: [
        Visibility(
          visible: denyText != '',
          child: TextButton(
            child: Text(denyText ?? AppStrings.cancel.toUpperCase(), style: TextStyle(),),
            onPressed: ()=> Get.back(result: false),
          ),
        ),
        TextButton(
          child: Text(confirmText ?? AppStrings.ok.toUpperCase(),style: TextStyle(color: AppColors.primary)),
          onPressed: ()=> Get.back(result: true),
        )
      ],
    );
  }
}