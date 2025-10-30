import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plex_user/constant/app_colors.dart';
import '../../modules/controllers/location/location_permission_controller.dart';
import '../../routes/appRoutes.dart';
import '../../routes/navigator_service.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      init: LocationController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/location.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 10),

                   Text(
                    'location_permission'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                   Text(
                    'location_permission_description'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),

                  ElevatedButton(
                    onPressed: controller.isButtonLoading ? null : controller.onContinueTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isButtonLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        :  Text(
                            'allow_permission'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    // ** 3. UPDATE OnPressed **
                    onPressed: controller.skipPermissionAndNavigate,
                    child:  Text(
                      'not_now'.tr,
                      style: TextStyle( fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      NavigatorService.pushNamed(AppRoutes.userHome);
    } else if (status.isDenied) {
      Get.snackbar(
        "Error",
        "Please Grant Location Permission.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    setState(() {
      _isLoading = false;
    });
  }
}
