import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';

class FooterBanner extends StatelessWidget {
  const FooterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(

        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text('sendAnything'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 6),
              Text( 'anywhere'.tr, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
            ],
          ),
          Container(
            width: 100,
            height: 100,
            child: const Icon(Icons.fire_truck_sharp, size: 40,color: Colors.white,),
          )
        ],
      ),
    );
  }
}
