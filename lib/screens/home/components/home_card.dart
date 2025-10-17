import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_assets.dart';
import 'package:plex_user/constant/app_colors.dart';

// ---------------------- Rewards Card ----------------------
class RewardsCard extends StatelessWidget {
  const RewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0,),
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset(AppAssets.trophy)),
                  SizedBox(width: 10,),
                  Text('exploreRewards'.tr, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18,color: AppColors.primary,)
          ],
        ),
      ),
    );
  }
}

// ---------------------- Help Card ----------------------
class HelpCard extends StatelessWidget {
  const HelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),

      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children:  [
            Expanded(child: Text('getHelp'.tr, style: TextStyle(fontSize: 14))),
            Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
