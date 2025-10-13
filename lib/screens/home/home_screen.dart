import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/search_field.dart';

import '../../constant/app_assets.dart';
import 'components/featured_banner.dart';
import 'components/footer_banner.dart';
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
             SearchAndFilterComponent(onTap: (){},isFilter: true,),
             const SizedBox(height: 12),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: const [
                   SizedBox(height: 8),
                   // PromoCarousel(),
                   BannerCarousel(),
                   // FeaturedBanner(),
                   SizedBox(height: 18),
                   MenusGrid(),
                   SizedBox(height: 18),
                   RewardsCard(),
                   SizedBox(height: 14),
                   HelpCard(),
                   SizedBox(height: 24),
                   Spacer(),
                   FooterBanner(),
                   SizedBox(height: 24),
                 ],
               ),
             ),
           ],
         ),
      ),
    );
  }
}

