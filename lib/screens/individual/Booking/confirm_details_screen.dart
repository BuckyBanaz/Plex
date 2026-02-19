import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Vehicle icon ke liye
import 'package:get/get.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import '../../../constant/app_assets.dart';
import '../../../modules/controllers/booking/booking_controller.dart';
import '../../widgets/helpers.dart';
import 'components/fare_row_item.dart';

class ConfirmDetailsScreen extends StatelessWidget {
  const ConfirmDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(CupertinoIcons.back),
        ),
        title:  Text(
          "confirm_details".tr,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          LocationSection(),
          SizedBox(height: 24),
          InfoSection(),
          SizedBox(height: 24),
          DiscountSection(),
          SizedBox(height: 24),
          FareDetailsSection(),
        ],
      ),
      bottomNavigationBar: Obx(
        () => CustomButton(
          onTap: controller.orderNow,
          widget: Center(
            child: controller.isLoading.value
                ? CircularProgressIndicator(
                    color: AppColors.textColor,
                    strokeWidth: 3,
                  )
                : Text(
                    "order_now".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Section 1: Location Details Card
class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    return Obx(() {
      // Access reactive values inside Obx
      final pickupAddress = controller.pAddress.value;
      final dropoffAddress = controller.dAddress.value;
      final selectedVehicleIndex = controller.selectedVehicleIndex.value;
      
      // Calculate vehicle icon asset reactively
      String vehicleIconAsset = AppAssets.bike;
      if (selectedVehicleIndex == 1) {
        vehicleIconAsset = AppAssets.car;
      } else if (selectedVehicleIndex == 2) {
        vehicleIconAsset = AppAssets.van;
      }

      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _DynamicLocationLayout(
              pickupAddress: pickupAddress,
              dropoffAddress: dropoffAddress,
              vehicleIconAsset: vehicleIconAsset,
            );
          },
        ),
      );
    });
  }
}

class _DynamicLocationLayout extends StatefulWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicleIconAsset;

  const _DynamicLocationLayout({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.vehicleIconAsset,
  });

  @override
  State<_DynamicLocationLayout> createState() => _DynamicLocationLayoutState();
}

class _DynamicLocationLayoutState extends State<_DynamicLocationLayout> {
  final GlobalKey _pickupLabelKey = GlobalKey();
  final GlobalKey _dropoffLabelKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();
  double? pickupLabelY;
  double? dropoffLabelY;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePositions());
  }

  @override
  void didUpdateWidget(_DynamicLocationLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickupAddress != widget.pickupAddress || 
        oldWidget.dropoffAddress != widget.dropoffAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measurePositions());
    }
  }

  void _measurePositions() {
    final pickupLabelContext = _pickupLabelKey.currentContext;
    final dropoffLabelContext = _dropoffLabelKey.currentContext;
    final cardContext = _cardKey.currentContext;
    
    if (pickupLabelContext != null && dropoffLabelContext != null && cardContext != null) {
      final pickupLabelBox = pickupLabelContext.findRenderObject() as RenderBox?;
      final dropoffLabelBox = dropoffLabelContext.findRenderObject() as RenderBox?;
      final cardBox = cardContext.findRenderObject() as RenderBox?;
      
      if (pickupLabelBox != null && dropoffLabelBox != null && cardBox != null) {
        // Get positions relative to the card
        final pickupLabelTop = pickupLabelBox.localToGlobal(Offset.zero).dy;
        final dropoffLabelTop = dropoffLabelBox.localToGlobal(Offset.zero).dy;
        final cardTop = cardBox.localToGlobal(Offset.zero).dy;
        
        // Center of pickup label text (relative to card top) - align icon with label
        final pickupLabelCenter = pickupLabelTop - cardTop + (pickupLabelBox.size.height / 2);
        
        // Center of dropoff label text (relative to card top) - align icon with label
        final dropoffLabelCenter = dropoffLabelTop - cardTop + (dropoffLabelBox.size.height / 2);
        
        setState(() {
          pickupLabelY = pickupLabelCenter;
          dropoffLabelY = dropoffLabelCenter;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate based on estimated heights if not measured yet
    final estimatedPickupHeight = _measureTextHeight(widget.pickupAddress, 15, MediaQuery.of(context).size.width - 100);
    
    // Label height is approximately 20px (fontSize 16 with line height)
    final labelHeight = 20.0;
    
    // Center of pickup label: half of label height
    final estimatedPickupLabelCenter = labelHeight / 2;
    // Center of dropoff label: pickup label + spacing + pickup address + gap + half of dropoff label
    final estimatedDropoffLabelCenter = labelHeight + 4.0 + estimatedPickupHeight + 16.0 + (labelHeight / 2);
    
    // Use measured label positions, fallback to estimated
    final pickupLabelCenter = pickupLabelY ?? estimatedPickupLabelCenter;
    final dropoffLabelCenter = dropoffLabelY ?? estimatedDropoffLabelCenter;
    final lineHeight = (dropoffLabelCenter - pickupLabelCenter).clamp(8.0, double.infinity);

    return Stack(
      key: _cardKey,
      children: [
        // Main content row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacer for icons
            const SizedBox(width: 28),
            const SizedBox(width: 12),
            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup Location Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key: _pickupLabelKey,
                              "pickup_location".tr,
                              style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.pickupAddress,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Vehicle Icon - attached to pickup location
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            widget.vehicleIconAsset,
                            matchTextDirection: true,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Delivery Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: _dropoffLabelKey,
                        "delivery_location".tr,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.dropoffAddress,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Icons positioned absolutely
        Positioned(
          left: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Position GPS icon at pickup label center
              SizedBox(height: (pickupLabelCenter - 8).clamp(0, double.infinity)),
              Icon(Icons.gps_fixed, color: AppColors.primary, size: 16),
              // Dynamic dotted line
              SizedBox(
                height: lineHeight,
                child: CustomPaint(
                  painter: DottedLinePainter(),
                  size: Size(2, lineHeight),
                ),
              ),
              // Position dropoff icon at dropoff label center
              SizedBox(height: (dropoffLabelCenter - pickupLabelCenter - lineHeight - 8).clamp(0, double.infinity)),
              const Icon(
                Icons.circle_outlined,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _measureTextHeight(String text, double fontSize, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.size.height;
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primarySwatch.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const dotSpacing = 4.0;
    final totalHeight = size.height;
    
    double currentY = dotRadius;
    while (currentY < totalHeight) {
      canvas.drawCircle(
        Offset(size.width / 2, currentY),
        dotRadius,
        paint,
      );
      currentY += dotRadius * 2 + dotSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// class InfoSection extends StatelessWidget {
//   const InfoSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final BookingController controller = Get.find<BookingController>();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             InfoColumnItem(
//               "Collect time",
//               controller.selectedTime.value == 0
//                   ? "Immediate"
//                   : "Scheduled", // Example
//             ),
//             InfoColumnItem(
//               "Weight",
//               "${controller.weight.value} ${controller.selectedWeightUnit.value}",
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             InfoColumnItem(
//               "Contact number",
//               controller.dmobileController.text,
//             ),
//             InfoColumnItem(
//               "Distance",
//               controller.distance.value.toString(),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  // Helper to calculate ETA from distance
  static String _calculateETAFromDistance(double distanceKm) {
    if (distanceKm <= 0) return "-";
    
    // Calculate ETA from distance (assuming average speed of 40 km/h)
    const avgSpeedKmh = 40.0;
    final hours = distanceKm / avgSpeedKmh;
    final minutes = (hours * 60).round();
    
    if (minutes < 1) {
      return "< 1 min";
    } else if (minutes < 60) {
      return "$minutes mins";
    } else {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (m == 0) {
        return "$h hour${h > 1 ? 's' : ''}";
      } else {
        return "$h hour${h > 1 ? 's' : ''} $m mins";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoColumnItem(
              "collect_time".tr,
              controller.selectedTime.value == 0 ? "immediate".tr : "schedule".tr,
            ),
            InfoColumnItem(
              "weight".tr,
              "${controller.weight.value} ${controller.selectedWeightUnit.value}",
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            InfoColumnItem("contact_number".tr, controller.dmobileController.text),
            // Distance + Duration stacked vertically
            Obx(
              () {
                // Access both reactive values to ensure updates
                final distance = controller.distance.value;
                final durationText = controller.durationText.value;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "distance".tr,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${distance.toStringAsFixed(2)} km",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "eta".tr,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      durationText.isNotEmpty ? durationText : _calculateETAFromDistance(distance),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}


/// Section 3: Discount Offers
class DiscountSection extends StatelessWidget {
  const DiscountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "discount_offers".tr,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => controller.isCouponApplied.value
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg, // Dark blue
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text("🎉", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            "coupon_applied".trParams({"coupon_code": controller.appliedCouponCode.value}),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: controller.removeCoupon,
                        child:  Text(
                          "remove".tr,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              :  Center(
                  child: Text(
                    "no_coupon_applied".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Section 4: Fare Details
// class FareDetailsSection extends StatelessWidget {
//   const FareDetailsSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final BookingController controller = Get.find<BookingController>();
//
//     return Column(
//       children: [
//         FareRowItem(
//           "Trip fare",
//           "₹${controller.tripFare.value.toStringAsFixed(2)}",
//           isBold: true,
//         ),
//         const SizedBox(height: 12),
//         Obx(
//               () => FareRowItem(
//             "Coupon Discount",
//             "-₹${controller.isCouponApplied.value ? controller.couponDiscount.value.toStringAsFixed(2) : '0.00'}",
//             isBold: true,
//           ),
//         ),
//         const SizedBox(height: 12),
//         FareRowItem(
//           "GST Charges (included in fare)",
//           "₹${controller.gstCharges.value.toStringAsFixed(2)}",
//           isBold: true,
//         ),
//         const Divider(height: 24),
//         Obx(
//               () => FareRowItem(
//             "Total fare",
//             "₹${controller.totalFare.toStringAsFixed(2)}",
//             isBold: true,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Obx(
//               () => FareRowItem(
//             "Amount payable",
//             "₹${controller.amountPayable.toStringAsFixed(2)}",
//             isBold: true,
//           ),
//         ),
//       ],
//     );
//   }
// }

class FareDetailsSection extends StatelessWidget {
  const FareDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    return Column(
      children: [
        // Show API estimated cost row (optional)
        Obx(
          () => FareRowItem(
            "estimated_price".tr,
            controller.estimatedCostINR.value > 0
                ? "₹${controller.estimatedCostINR.value.toStringAsFixed(2)} "
                // ? "₹${controller.estimatedCostINR.value.toStringAsFixed(2)} (${controller.currency.value})"
                : "Fetching...",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        FareRowItem(
          "trip_fare".tr,
          "₹${controller.tripFare.value.toStringAsFixed(2)}",
          isBold: true,
        ),
        const SizedBox(height: 12),
        Obx(
          () => FareRowItem(
            "coupon_discount".tr,
            "-₹${controller.isCouponApplied.value ? controller.couponDiscount.value.toStringAsFixed(2) : '0.00'}",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        FareRowItem(
          "gst_charges".tr,
          "₹${controller.gstCharges.value.toStringAsFixed(2)}",
          isBold: true,
        ),
        const Divider(height: 24),
        Obx(
          () => FareRowItem(
            "total_fare".tr,
            "₹${controller.totalFare.toStringAsFixed(2)}",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => FareRowItem(
            "amount_payable".tr,
            "₹${controller.amountPayable.toStringAsFixed(2)}",
            isBold: true,
          ),
        ),
      ],
    );
  }
}
