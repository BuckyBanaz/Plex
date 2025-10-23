import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Vehicle icon ke liye
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../../modules/contollers/booking/booking_controller.dart';

class ConfirmDetailsScreen extends StatelessWidget {
  const ConfirmDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final BookingController controller = Get.put(
      BookingController(),
    );

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
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLocationSection(controller),
          const SizedBox(height: 24),
          _buildInfoSection(controller),
          const SizedBox(height: 24),
          _buildDiscountSection(controller),
          const SizedBox(height: 24),
          _buildFareDetailsSection(controller),
        ],
      ),
      bottomNavigationBar: _buildOrderNowButton(controller),
    );
  }

  Widget _buildLocationSection(BookingController controller) {

    String vehicleIconAsset = 'assets/icons/bike.svg';
    if (controller.selectedVehicleIndex.value == 1) {
      vehicleIconAsset = 'assets/icons/car.svg';
    } else if (controller.selectedVehicleIndex.value == 2) {
      vehicleIconAsset = 'assets/icons/van.svg';
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
              const Icon(Icons.gps_fixed, color: Colors.orange, size: 12),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: Colors.orange[200],
                size: 4,
              ),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: Colors.orange[200],
                size: 4,
              ),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: Colors.orange[200],
                size: 4,
              ),
              SizedBox(height: 2),
              Icon(
                Icons.fiber_manual_record,
                color: Colors.orange[200],
                size: 4,
              ),
              SizedBox(height: 2),
              const Icon(Icons.circle_outlined, color: Colors.orange, size: 12),
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
                    SvgPicture.asset(
                      vehicleIconAsset,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                Text(
                   controller.pAddressController.text,
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
                  // "21b, Karimu Kotun Street, Victoria Island",
                   controller.daddressController.text,
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

  Widget _buildInfoSection(BookingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn(
              "Collect time",
              controller.selectedTime.value == 0
                  ? "Immediate"
                  : "Scheduled", // Example
            ),
            _buildInfoColumn(
              "Weight",
              "${controller.weight.value} ${controller.selectedWeightUnit.value}",
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoColumn(
          "Contact number",
          controller.dmobileController.text,
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String subtitle) {
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDiscountSection(BookingController controller) {
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
                    color: const Color(0xFF3A3A5C), // Dark blue
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
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    "No coupon applied.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFareDetailsSection(BookingController controller) {
    return Column(
      children: [
        const Divider(height: 20),
        _buildFareRow(
          "Trip fare",
          "₹${controller.tripFare.value.toStringAsFixed(2)}",
          isBold: true,
        ),
        const SizedBox(height: 12),
        Obx(
          () => _buildFareRow(
            "Coupon Discount",
            "-₹${controller.isCouponApplied.value ? controller.couponDiscount.value.toStringAsFixed(2) : '0.00'}",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        _buildFareRow(
          "GST Charges (included in fare)",
          "₹${controller.gstCharges.value.toStringAsFixed(2)}",
          isBold: true,
        ),
        const Divider(height: 24),
        Obx(
          () => _buildFareRow(
            "Total fare",
            "₹${controller.totalFare.toStringAsFixed(2)}",
            isBold: true,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _buildFareRow(
            "Amount payable",
            "₹${controller.amountPayable.toStringAsFixed(2)}",
            isBold: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFareRow(String title, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isBold ? Colors.black : Colors.grey[700],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderNowButton(BookingController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
      color: Colors.white,
      child: GestureDetector(
        onTap: controller.orderNow,
        child: Container(
          height: 55.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.orange, // Orange color
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Center(
            child: Text(
              "Order Now",
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
