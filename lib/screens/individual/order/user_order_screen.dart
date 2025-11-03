import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:plex_user/modules/controllers/orders/order_controller.dart';

import '../../../constant/app_colors.dart';
import '../../order/components/driver_delivery_order_card.dart' show OrderCard;
import 'components/order_card_widget.dart';

// class UserOrderScreen extends StatefulWidget {
//   const UserOrderScreen({super.key});
//
//   @override
//   State<UserOrderScreen> createState() => _UserOrderScreenState();
// }
//
// class _UserOrderScreenState extends State<UserOrderScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(child: Center(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset('assets/images/noorder.png'),
//               SizedBox(height: 10,),
//               Text("No order history yet",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//               SizedBox(height: 10,),
//               Text("When you have Order done, you will see them here",style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
//               SizedBox(height: 10,),
//               ElevatedButton(onPressed: (){}, child: Text("Refresh"))
//             ],
//           ),
//         ),
//       )),
//     );
//   }
// }
class UserOrderScreen extends StatelessWidget {
  const UserOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserOrderController controller =Get.put(UserOrderController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title:  Text("Orders",style: TextStyle(color: AppColors.textColor),),
        centerTitle: true,
        elevation: 0,
      ),

      body: Obx(
            () {
          if (controller.groupedOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.groupedOrders.keys.length,
            itemBuilder: (context, index) {
              String groupTitle =
              controller.groupedOrders.keys.elementAt(index);
              var orders = controller.groupedOrders[groupTitle]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 8.0, bottom: 12.0, left: 4.0),
                    child: Text(
                      groupTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  ...orders.map((order) => OrderCard(order: order)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}