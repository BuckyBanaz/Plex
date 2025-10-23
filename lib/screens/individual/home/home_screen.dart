import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/routes/appRoutes.dart';
import 'package:plex_user/screens/widgets/search_field.dart';

import '../../../constant/app_assets.dart';
import 'components/featured_banner.dart';
import 'components/footer_banner.dart';
import 'components/delivery_option_card.dart';
import 'components/home_card.dart';
import 'components/menu_list.dart';
import 'components/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
           children: [
             const TopBar(),
             // SearchAndFilterComponent(onTap: (){},isFilter: true,),
             const SizedBox(height: 12),
             Expanded(
               child: ListView(
                 // crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const SizedBox(height: 8),

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
                     onTap: () {
                       Get.toNamed(AppRoutes.booking);
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

