import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plex_user/modules/controllers/orders/user_order_controller.dart';

import '../../../constant/app_colors.dart';
import '../../order/components/driver_delivery_order_card.dart' show OrderCard;
import 'components/order_card_widget.dart';

class UserOrderScreen extends StatelessWidget {
  const UserOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserOrderController controller = Get.put(UserOrderController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(
          "Orders",
          style: TextStyle(color: AppColors.textColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
            () {
          // loading state
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // no orders state (not loading and groupedOrders empty)
          if (controller.groupedOrders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => controller.refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ensure this asset exists in your project
                        Image.asset(
                          'assets/images/noorder.png',
                          height: 160,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No order history yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "When you have orders done, you will see them here.",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () => controller.refresh(),
                          child: const Text("Refresh"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // has orders -> show grouped list with pull-to-refresh
          final groupKeys = controller.groupedOrders.keys.toList();

          return RefreshIndicator(
            onRefresh: () async => controller.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: groupKeys.length,
              itemBuilder: (context, index) {
                final String groupTitle = groupKeys[index];
                final orders = controller.groupedOrders[groupTitle]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 12.0, left: 4.0),
                      child: Text(
                        groupTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    ...orders.map(
                          (order) => GestureDetector(
                        onTap: () => controller.goToOrderDetails(order),
                        child: OrderCard(order: order),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
