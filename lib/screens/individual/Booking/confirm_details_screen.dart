import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Vehicle icon ke liye
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import '../../../constant/app_assets.dart';
import '../../../modules/controllers/booking/booking_controller.dart';
import 'components/fare_row_item.dart';


class ConfirmDetailsScreen extends StatelessWidget {
  const ConfirmDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
   final controller =  Get.put(BookingController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrow_left_2),
        ),
        title: const Text(
          "Confirm Details",
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
      bottomNavigationBar: Obx(() => CustomButton(onTap: controller.orderNow,widget: Center(
        child: controller.isLoading.value ? CircularProgressIndicator(color: AppColors.textColor,strokeWidth: 3,) : Text(
          "Order Now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),),)
    );
  }
}


/// Section 1: Location Details Card
class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    String vehicleIconAsset = AppAssets.bike;
    if (controller.selectedVehicleIndex.value == 1) {
      vehicleIconAsset = AppAssets.car;
    } else if (controller.selectedVehicleIndex.value == 2) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 4),
              Icon(Icons.gps_fixed, color: AppColors.primary, size: 12),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: AppColors.primarySwatch.shade200,
                size: 4,
              ),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: AppColors.primarySwatch.shade200,
                size: 4,
              ),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color:AppColors.primarySwatch.shade200,
                size: 4,
              ),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: AppColors.primarySwatch.shade200,
                size: 4,
              ),
              SizedBox(height: 2),
              const Icon(Icons.circle_outlined, color: AppColors.primary, size: 12),
            ],
          ),
          const SizedBox(width: 12),
          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pickup Location",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                    ),
                    // Vehicle Icon
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color:AppColors.cardColor,
                        borderRadius: BorderRadius.circular(8),

                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          vehicleIconAsset,
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
                Text(
                  controller.pAddress.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Delivery Location",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                ),
                Text(
                  controller.dAddress.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
              "Collect time",
              controller.selectedTime.value == 0 ? "Immediate" : "Scheduled",
            ),
            InfoColumnItem(
              "Weight",
              "${controller.weight.value} ${controller.selectedWeightUnit.value}",
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            InfoColumnItem(
              "Contact number",
              controller.dmobileController.text,
            ),
            // Distance + Duration stacked vertically
            Obx(
                  () => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Distance", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    "${controller.distance.value.toStringAsFixed(2)} km",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text("ETA", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    controller.durationText.value.isNotEmpty ? controller.durationText.value : "-",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}



/// Reusable helper widget for the Info Section
class InfoColumnItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const InfoColumnItem(this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
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
        const Text(
          "Discount offers",
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
                      "You applied 20 with ${controller.appliedCouponCode.value}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: controller.removeCoupon,
                  child: const Text(
                    "Remove",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
              : const Center(
            child: Text(
              "No coupon applied.",
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
            "Estimated Price",
            controller.estimatedCostINR.value > 0
                ? "₹${controller.estimatedCostINR.value.toStringAsFixed(2)} "
                // ? "₹${controller.estimatedCostINR.value.toStringAsFixed(2)} (${controller.currency.value})"
                : "Fetching...",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        FareRowItem(
          "Trip fare",
          "₹${controller.tripFare.value.toStringAsFixed(2)}",
          isBold: true,
        ),
        const SizedBox(height: 12),
        Obx(
              () => FareRowItem(
            "Coupon Discount",
            "-₹${controller.isCouponApplied.value ? controller.couponDiscount.value.toStringAsFixed(2) : '0.00'}",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        FareRowItem(
          "GST Charges (included in fare)",
          "₹${controller.gstCharges.value.toStringAsFixed(2)}",
          isBold: true,
        ),
        const Divider(height: 24),
        Obx(
              () => FareRowItem(
            "Total fare",
            "₹${controller.totalFare.toStringAsFixed(2)}",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
              () => FareRowItem(
            "Amount payable",
            "₹${controller.amountPayable.toStringAsFixed(2)}",
            isBold: true,
          ),
        ),
      ],
    );
  }
}


