import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plex_user/constant/app_assets.dart';
import '../../../../constant/app_colors.dart';
import '../../../../modules/controllers/booking/booking_controller.dart';

import 'package:get/get.dart';

class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {

    final BookingController controller = Get.find();

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildVehicleOption(
            controller: controller,
            svgAsset: AppAssets.bike,
            index: 0,
            isSelected: controller.selectedVehicleIndex.value == 0,
          ),
          _buildVehicleOption(
            controller: controller,
            svgAsset: AppAssets.car,
            index: 1,
            isSelected: controller.selectedVehicleIndex.value == 1,
          ),
          _buildVehicleOption(
            controller: controller,
            svgAsset: AppAssets.van,
            index: 2,
            isSelected: controller.selectedVehicleIndex.value == 2,
          ),
        ],
      ),
    );
  }


  Widget _buildVehicleOption({
    required BookingController controller,
    required String svgAsset,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        controller.selectVehicle(index);
      },
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3E7) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            matchTextDirection: true,
            svgAsset,
            height: 30,
            width: 30,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
