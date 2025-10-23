import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_assets.dart';
import 'package:plex_user/constant/app_colors.dart';

class FooterBanner extends StatelessWidget {
  const FooterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50,left: 16),
      child: Row(

        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Row(
                children: [
                  Text('sendAnything'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  SizedBox(width: 40,),
                  Image.asset(AppAssets.truck,)
                ],
              ),
              Text( 'anywhere'.tr, style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
            ],
          ),

        ],
      ),
    );
  }
}
