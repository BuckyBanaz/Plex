// ---------------------- Menus grid ----------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constant/app_colors.dart';

class MenusGrid extends StatelessWidget {
  const MenusGrid({super.key});


  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(title: 'deliveries'.tr, icon: Icons.local_shipping),
      _MenuItem(title: 'myOrder'.tr, icon: Icons.list_alt),
      _MenuItem(title: 'support'.tr, icon: Icons.support_agent),
      _MenuItem(title: 'setting'.tr, icon: Icons.settings),
    ];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),

          child: Text('menus'.tr, style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final it = items[index];
                return MenuCard(item: it);
              },
            ),
          ),
        ),
      ],
    );
  }
}
class _MenuItem {
  final String title;
  final IconData icon;
  _MenuItem({required this.title, required this.icon});
}

class MenuCard extends StatelessWidget {
  final _MenuItem item;
  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary),
            // boxShadow: [
            //   BoxShadow(color: Colors.black12, blurRadius: 2, offset: const Offset(0, 1)),
            // ],
          ),
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 26, color:AppColors.primary),
              const SizedBox(height: 6),
              Text(item.title, style: const TextStyle(fontSize: 12)),
            ],
          )),
        ),

      ],
    );
  }
}
