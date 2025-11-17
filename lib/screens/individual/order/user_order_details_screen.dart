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
import '../../../../models/driver_order_model.dart';
import '../../../modules/controllers/orders/user_order_controller.dart';

class UserOrderDetailsScreen extends GetView<UserOrderController> {
  const UserOrderDetailsScreen({super.key});

  // --- Helpers ---
  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    final date = "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    final time = "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    return "$date • $time";
  }

  Widget _buildStatusChip(OrderStatus status) {
    String text;
    Color bg = AppColors.primary;

    switch (status) {
      case OrderStatus.Delivered:
        text = "Completed";
        bg = Colors.green.shade600;
        break;
      case OrderStatus.Pending:
        text = "Pending";
        bg = Colors.orange.shade600;
        break;
      case OrderStatus.Cancelled:
        text = "Cancelled";
        bg = Colors.red.shade600;
        break;
      case OrderStatus.Created:
        text = "Created";
        bg = AppColors.primary;
        break;
      case OrderStatus.Assigned:
        text = "Assigned";
        bg = Colors.blue.shade600;
        break;
      case OrderStatus.Accepted:
        text = "Accepted";
        bg = Colors.teal.shade600;
        break;
      case OrderStatus.InTransit:
        text = "In Transit";
        bg = Colors.indigo.shade600;
        break;
      case OrderStatus.Declined:
        text = "Declined";
        bg = Colors.grey.shade600;
        break;
      default:
        text = "Unknown";
        bg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRatingStars(String ratingString) {
    double rating = double.tryParse(ratingString) ?? 0.0;
    int filledStars = rating.floor();
    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < filledStars) {
        stars.add(Icon(IconlyBold.star, color: AppColors.primary, size: 16));
      } else {
        stars.add(Icon(IconlyBold.star, color: Colors.grey.shade300, size: 16));
      }
    }

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
              final url = imageUrls[index];
              return Container(
                margin: const EdgeInsets.only(right: 10.0),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  image: url.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: url.isEmpty ? const Center(child: Icon(Icons.image_not_supported)) : null,
              );
            },
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  List<String> _extractImages(OrderModel order) {
    try {
      final imgs = (order.images ?? []).map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      return List<String>.from(imgs);
    } catch (_) {
      return <String>[];
    }
  }

  // --- End helpers ---

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = controller.selectedOrder.value;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Order Details",
            style: TextStyle(color: AppColors.textColor),
          ),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textColor,
        ),
        body: const Center(
          child: Text("No order selected."),
        ),
      );
    }

    String vehicleIconAsset = AppAssets.bike;
    if ((order.vehicleType ?? '').toLowerCase() == "car") {
      vehicleIconAsset = AppAssets.car;
    } else if ((order.vehicleType ?? '').toLowerCase() == "van") {
      vehicleIconAsset = AppAssets.van;
    }

    // driver details safe read
    final Map<String, dynamic>? driver = order.driverDetails;
    final driverName = driver != null ? (driver['name']?.toString() ?? 'Driver') : 'No driver';
    final driverPhone = driver != null ? (driver['phone']?.toString() ?? '-') : '-';

    final images = _extractImages(order);
    final pickupImages = images.isEmpty ? <String>[] : images.sublist(0, (images.length / 2).ceil());
    final deliveryImages = images.length <= 1 ? <String>[] : images.sublist((images.length / 2).ceil());

    // collect time display logic
    final collectType = order.collectTime?.type ?? 'immediate';
    final scheduledAt = order.collectTime?.scheduledAt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text("Order Details", style: TextStyle(color: AppColors.textColor)),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(CupertinoIcons.back, color: AppColors.textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row: createdAt, status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(order.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                // reactive status chip (order.status is Rx<OrderStatus> in model)
                Obx(() => _buildStatusChip(order.status.value)),
              ],
            ),
            const SizedBox(height: 16.0),

            // Driver / partner info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        driverPhone,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // optionally show rating if available in driver map
                      if (driver != null && driver['rating'] != null)
                        _buildRatingStars(driver['rating'].toString()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SvgPicture.asset(
                    vehicleIconAsset,
                    matchTextDirection: true,
                    height: 20,
                    colorFilter:  ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Order id
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                    text: "Order id - ",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: order.id,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Pickup / Drop
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
                      Icon(Icons.location_on, color: AppColors.secondary, size: 16.0),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pickup",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        order.pickup.address,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        "Drop off",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        order.dropoff.address,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Collect time (immediate or scheduled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Collect Time", style: TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      collectType.capitalizeFirst!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    if (collectType.toLowerCase() == 'scheduled')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          scheduledAt != null ? _formatDateTime(scheduledAt) : 'Scheduled time not set',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: InfoColumnItem("Vehicle Type", order.vehicleType ?? '-')),
                Expanded(child: InfoColumnItem("Weight", order.weight ?? '-')),
                Expanded(child: InfoColumnItem("Fee", order.estimatedCost?.toString() ?? '-')),
                Expanded(child: InfoColumnItem("Payment Method", order.paymentMethod?.toString() ?? '-')),
              ],
            ),
            const SizedBox(height: 24.0),

            // Images (if any)
            if (pickupImages.isNotEmpty) _buildImageGallery("Pickup image(s)", pickupImages),
            if (deliveryImages.isNotEmpty) _buildImageGallery("Delivery image(s)", deliveryImages),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
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
