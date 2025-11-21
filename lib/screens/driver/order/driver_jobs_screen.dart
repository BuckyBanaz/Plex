import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:plex_user/modules/controllers/home/driver_home_controller.dart';

import 'components/driver_jobs_card.dart';

class DriverJobsScreen extends StatefulWidget {
  const DriverJobsScreen({super.key});

  @override
  State<DriverJobsScreen> createState() => _DriverJobsScreenState();
}

class _DriverJobsScreenState extends State<DriverJobsScreen> {
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
                  child: DriverJobsCard(order: order),
                );
              },
            ),
          ),
    );
  }
}
