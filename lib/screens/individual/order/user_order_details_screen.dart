// /screens/order_details_screen.dart

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/individual/Booking/shipment_tracking_screen.dart';
import 'package:plex_user/screens/widgets/helpers.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';
import '../../../../constant/app_assets.dart';
import '../../../../models/driver_order_model.dart';
import '../../../modules/controllers/orders/user_order_controller.dart';
import '../../../modules/controllers/booking/shipment_tracking_controller.dart';
import '../../../modules/controllers/booking/search_driver_controller.dart';

class UserOrderDetailsScreen extends GetView<UserOrderController> {
  const UserOrderDetailsScreen({super.key});

  // --- Helpers ---
  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    final date =
        "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    final time =
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
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
      case OrderStatus.PickedUp:
        text = "Picked Up";
        bg = Colors.purple.shade600;
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

  Widget _buildTrackButton(BuildContext context) {
    final order = controller.selectedOrder.value;

    return Obx(() {
      final isLoadingLocation = controller.isLoadingDriverLocation.value;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isLoadingLocation
              ? null
              : () {
                  if (order == null) return;

                  // Get driver details from order
                  final driverDetails = order.driverDetails;
                  if (driverDetails == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Driver information not available"),
                      ),
                    );
                    return;
                  }

                  // Create DriverModel
                  final driver = DriverModel(
                    id: driverDetails['driverId'] ?? '',
                    name: driverDetails['name'] ?? '',
                    lat: driverDetails['lat'] ?? 0.0,
                    lng: driverDetails['lng'] ?? 0.0,
                    vehicle: driverDetails['vehicle'] ?? '',
                    avatarUrl: driverDetails['profile'].toString(),
                  );

                  final driverLocation = controller.driverLocation.value;

                  // Initialize tracking controller
                  final trackingController = Get.put(ShipmentTrackingController());
                  trackingController.startTracking(order);


                  // Navigate to tracking screen
                  Get.to(() => ShipmentTrackingScreen(order: order));
                },
          child: isLoadingLocation
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  "Track Your Package",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }

  String getInitials(String name) {
    if (name.isEmpty) return "?";

    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase(); // Single name
    }
    return (parts[0][0] + parts[1][0]).toUpperCase(); // First + Last initials
  }

  Widget buildProfileAvatar(String? imageUrl, String driverName) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl));
    }

    // initials fallback
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary,
      child: Text(
        getInitials(driverName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
                      child: url.isEmpty
                          ? const Center(child: Icon(Icons.image_not_supported))
                          : null,
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
      final imgs = (order.images ?? [])
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      return List<String>.from(imgs);
    } catch (_) {
      return <String>[];
    }
  }

  // OTP Section for User
  Widget _buildOtpSection(OrderModel order) {
    // Only show OTPs when driver is assigned
    final shouldShow = order.status.value == OrderStatus.Accepted ||
        order.status.value == OrderStatus.Assigned ||
        order.status.value == OrderStatus.PickedUp ||
        order.status.value == OrderStatus.InTransit;
    
    if (!shouldShow) return const SizedBox.shrink();

    final pickupOtp = order.pickupOtp ?? '';
    final dropoffOtp = order.dropoffOtp ?? '';
    final isPickedUp = order.status.value == OrderStatus.PickedUp ||
        order.status.value == OrderStatus.InTransit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Verification OTPs",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Share these OTPs with the driver to verify pickup and delivery",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Pickup OTP Card
            Expanded(
              child: _buildOtpCard(
                title: "Pickup OTP",
                otp: pickupOtp,
                icon: Icons.local_shipping_outlined,
                isVerified: isPickedUp,
                color: isPickedUp ? Colors.green : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Dropoff OTP Card
            Expanded(
              child: _buildOtpCard(
                title: "Delivery OTP",
                otp: dropoffOtp,
                icon: Icons.location_on_outlined,
                isVerified: order.status.value == OrderStatus.Delivered,
                color: order.status.value == OrderStatus.Delivered 
                    ? Colors.green 
                    : Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpCard({
    required String title,
    required String otp,
    required IconData icon,
    required bool isVerified,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green.shade200 : color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isVerified ? Colors.green : color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isVerified) ...[
                const Spacer(),
                Icon(Icons.check_circle, size: 16, color: Colors.green),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (isVerified)
            Text(
              "Verified",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.green,
                letterSpacing: 2,
              ),
            )
          else
            Text(
              otp.isNotEmpty ? otp : "----",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 8,
              ),
            ),
        ],
      ),
    );
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
        body: const Center(child: Text("No order selected.")),
      );
    }

    // Fetch driver location when screen opens (if order is in transit/accepted/assigned)
    final shouldFetchLocation =
        order.status.value == OrderStatus.InTransit ||
        order.status.value == OrderStatus.Accepted ||
        order.status.value == OrderStatus.Assigned;

    if (shouldFetchLocation &&
        controller.driverLocation.value == null &&
        !controller.isLoadingDriverLocation.value) {
      // Fetch driver location in the background
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchDriverLocation(order.id);
      });
    }

    String vehicleIconAsset = AppAssets.bike;
    if ((order.vehicleType ?? '').toLowerCase() == "car") {
      vehicleIconAsset = AppAssets.car;
    } else if ((order.vehicleType ?? '').toLowerCase() == "van") {
      vehicleIconAsset = AppAssets.van;
    }

    // driver details safe read
    final Map<String, dynamic>? driver = order.driverDetails;
    final driverName = driver != null
        ? (driver['name']?.toString() ?? 'Driver')
        : 'No driver';
    final driverPhone = driver != null
        ? (driver['phone']?.toString() ?? '-')
        : '-';

    final images = _extractImages(order);
    final pickupImages = images.isEmpty
        ? <String>[]
        : images.sublist(0, (images.length / 2).ceil());
    final deliveryImages = images.length <= 1
        ? <String>[]
        : images.sublist((images.length / 2).ceil());

    // collect time display logic
    final collectType = order.collectTime?.type ?? 'immediate';
    final scheduledAt = order.collectTime?.scheduledAt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text(
          "Order Details",
          style: TextStyle(color: AppColors.textColor),
        ),
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
                  child: Row(
                    children: [
                      buildProfileAvatar(driver?['profile'], driverName),
                      SizedBox(width: 12.0),
                      Column(
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
                    colorFilter: ColorFilter.mode(
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
                      Icon(
                        IconlyBold.location,
                        color: AppColors.secondary,
                        size: 16.0,
                      ),
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            if (order.status.value == OrderStatus.InTransit ||
                order.status.value == OrderStatus.PickedUp ||
                order.status.value == OrderStatus.Accepted ||
                order.status.value == OrderStatus.Assigned) ...[
              const SizedBox(height: 20),
              _buildTrackButton(context),
            ],
            
            // OTP Verification Cards
            _buildOtpSection(order),
            
            const SizedBox(height: 20),

            // Collect time (immediate or scheduled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Collect Time",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      collectType.capitalizeFirst!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (collectType.toLowerCase() == 'scheduled')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          scheduledAt != null
                              ? _formatDateTime(scheduledAt)
                              : 'Scheduled time not set',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
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
                Expanded(
                  child: InfoColumnItem(
                    "Vehicle Type",
                    order.vehicleType ?? '-',
                  ),
                ),
                Expanded(child: InfoColumnItem("Weight", order.weight ?? '-')),
                Expanded(
                  child: InfoColumnItem(
                    "Fee",
                    order.estimatedCost?.toString() ?? '-',
                  ),
                ),
                Expanded(
                  child: InfoColumnItem(
                    "Payment Method",
                    order.paymentMethod?.toString() ?? '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Images (if any)
            if (pickupImages.isNotEmpty)
              _buildImageGallery("Pickup image(s)", pickupImages),
            if (deliveryImages.isNotEmpty)
              _buildImageGallery("Delivery image(s)", deliveryImages),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  CustomSnackbar.info(
                    "Need help functionality not implemented yet.",
                    title: "Help",
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
