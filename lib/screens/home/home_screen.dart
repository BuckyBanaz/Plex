import 'package:flutter/material.dart';
import 'package:plex_user/constant/app_colors.dart';

import '../../constant/app_assets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(

      ),

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(AppAssets.logo, width: 200,),
            ),
            Text("Comming Soon",style: TextStyle(
              color: AppColors.primary,
              fontSize: 20
            ),)
          ],
        ),
      ),
    );
  }
}
