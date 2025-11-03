// /screens/order_details_screen.dart

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/helpers.dart';
import '../../../../constant/app_assets.dart';
import '../../../../modules/controllers/orders/order_controller.dart';

class OrderDetailsScreen extends GetView<UserOrderController> {
  const OrderDetailsScreen({super.key});

  Widget _buildStatusChip(OrderStatus status) {
    String text;

    switch (status) {
      case OrderStatus.Complete:
        text = "Completed";
        break;
      case OrderStatus.Pending:
        text = "Pending";
        break;
      case OrderStatus.Cancelled:
        text = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildRatingStars(String ratingString) {
    double rating = double.tryParse(ratingString) ?? 0.0;
    int filledStars = rating.floor(); // Yeh integer part nikalega (e.g., 4.1 -> 4)
    List<Widget> stars = [];

    // 5 stars
    for (int i = 0; i < 5; i++) {
      if (i < filledStars) {
        stars.add(Icon(IconlyBold.star, color: AppColors.primary, size: 16));
      } else {

        stars.add(Icon(IconlyBold.star, color: Colors.grey.shade300, size: 16));
      }
    }

    // Rating ka text
    stars.add(const SizedBox(width: 4.0));
    stars.add(
      Text(
        ratingString,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Row(children: stars);
  }
  Widget _buildImageGallery(String title, List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        imageUrls.isEmpty
            ? const Text(
          "No images available.",
          style: TextStyle(color: Colors.black54),
        )
            : SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 10.0),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = controller.selectedOrder.value;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title:  Text("Order Details",style: TextStyle(color:AppColors.textColor ),),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textColor,
        ),
        body: const Center(
          child: Text("No order selected."),
        ),
      );
    }

    String vehicleIconAsset = AppAssets.bike;
    if (order.vehicleType == "Car") {
      vehicleIconAsset = AppAssets.car;
    } else if (order.vehicleType == "Van") {
      vehicleIconAsset = AppAssets.van;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title:  Text("Orders Details",style: TextStyle(color: AppColors.textColor),),
        elevation: 0,
        leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(CupertinoIcons.back,color: AppColors.textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${order.date}, ${order.time}",
              style: const TextStyle(

                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16.0),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(order.deliverPartnerProfilePic),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliverPartnerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "Deliver parter",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // Row(
                      //   children: [
                      //     Icon(Icons.star, color: AppColors.primary, size: 16),
                      //     const SizedBox(width: 4.0),
                      //     Text(
                      //       order.deliverPartnerRating,
                      //       style: const TextStyle(
                      //         color: Colors.black,
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      _buildRatingStars(order.deliverPartnerRating),
                    ],
                  ),
                ),

                _buildStatusChip(order.status),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.secondary, // Dark blue
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SvgPicture.asset(
                    vehicleIconAsset,
                    matchTextDirection: true,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary, // Orange icon
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // === Order ID ===
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  const TextSpan(
                    text: "Order id - ",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: order.orderId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Column(
                    children: [
                      Icon(Icons.circle, color: AppColors.primary, size: 12.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: DottedLine(
                          direction: Axis.vertical,
                          lineLength: 40,
                          dashColor: Colors.grey.shade400,
                          dashGapLength: 3.0,
                          dashRadius: 2.0,
                        ),
                      ),
                      Icon(Icons.location_on,
                          color: AppColors.secondary, size: 16.0),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pickup",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        order.pickupAddress,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        "Drop off",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        order.dropoffAddress,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: InfoColumnItem("collect_time".tr, order.collectTime)),
                Expanded(child: InfoColumnItem("Vehicle Type", order.vehicleType)),
                Expanded(child: InfoColumnItem( "weight".tr, order.weight)),
              ],
            ),
            const SizedBox(height: 24.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: InfoColumnItem("Payment", order.paymentMethod)),
                Expanded(child: InfoColumnItem("Fee", order.fee)),
                const Expanded(child: SizedBox()), // Empty space for alignment
              ],
            ),
            const SizedBox(height: 24.0),

            _buildImageGallery("Pickup image(s)", order.pickupImageUrls),

            _buildImageGallery("Delivery image(s)", order.deliveryImageUrls),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement "Need help?" functionality
                  Get.snackbar(
                    "Help",
                    "Need help functionality not implemented yet.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                  );
                },
                child: const Text(
                  "Need help?",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}