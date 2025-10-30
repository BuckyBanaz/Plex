import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:plex_user/modules/controllers/home/driver_home_controller.dart';

import 'components/driver_delivery_order_card.dart';

class DriverDeliveryOrderScreen extends StatefulWidget {
  const DriverDeliveryOrderScreen({super.key});

  @override
  State<DriverDeliveryOrderScreen> createState() => _DriverDeliveryOrderScreenState();
}

class _DriverDeliveryOrderScreenState extends State<DriverDeliveryOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final DriverHomeController controller = Get.put(DriverHomeController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(Icons.arrow_back_ios)),

        title: Text("newOrder".tr),
        elevation: 0,
      ),
      body: Obx(
      () => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.orders.length,
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: OrderCard(order: order),
                );
              },
            ),
          ),
    );
  }
}
