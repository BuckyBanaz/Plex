import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';

import '../../../../modules/controllers/home/driver_home_controller.dart';

class RecentHistoryList extends StatelessWidget {
  final DriverHomeController controller;
  const RecentHistoryList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: controller.recentHistory.length,
                itemBuilder: (context, index) {
                  final item = controller.recentHistory[index];

                  return _OrderListCard(
                    name: item['name']!,
                    time: item['time']!,
                    amount: item['amount']!,
                    initial: item['initial']!,
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 1, color: Colors.black12);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListCard extends StatelessWidget {
  final String name;
  final String time;
  final String amount;
  final String initial;

  const _OrderListCard({
    required this.name,
    required this.time,
    required this.amount,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.driverCard,
        child: Text(
          initial,
          style:  TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            const Icon(IconlyLight.calendar, size: 14, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              time,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
      trailing: Text(
        '\$ $amount',
        style:  TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
