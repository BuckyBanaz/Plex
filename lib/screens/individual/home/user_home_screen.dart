import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../../../constant/app_assets.dart';

import '../../../services/domain/repository/repository_imports.dart';
import 'components/footer_banner.dart';
import 'components/delivery_option_card.dart';
import 'components/menu_list.dart';
import 'components/top_bar.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
           children: [
             const TopBar(),
             // SearchAndFilterComponent(onTap: (){},isFilter: true,),
             Expanded(
               child: ListView(
                 children: [

                   DeliveryOptionCard(
                     title: 'Local Delivery',
                     subtitle: 'Book now!',
                     imagePath: AppAssets.locale,
                     badgeText: '15 mins',
                     onTap: () {
                       Get.toNamed(AppRoutes.booking);
                       print('Local delivery tapped');
                     },
                   ),
                   DeliveryOptionCard(
                     title: 'City to city',
                     subtitle: 'Book now!',
                     imagePath: AppAssets.intraCity,
                     onTap: () async {
                       await AuthRepository().refreshToken();
                       // Get.toNamed(AppRoutes.booking);
                       print('City to city tapped');
                     },
                   ),



                   // // PromoCarousel(),
                   // BannerCarousel(),
                   // // FeaturedBanner(),
                   // SizedBox(height: 18),
                   MenusGrid(),
                   SizedBox(height: 18),
                   // const SizedBox(height: 14),
                   // const RewardsCard(),
                   // const SizedBox(height: 14),
                   // const HelpCard(),
                   const SizedBox(height: 24),
                   const FooterBanner(),
                 ],
               ),
             ),
           ],
         ),
      ),
    );
  }
}

