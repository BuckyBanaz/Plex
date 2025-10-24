
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../common/Toast/toast.dart';
import '../../../routes/appRoutes.dart';
import '../../../services/domain/service/app/app_service_imports.dart';



class LocationController extends GetxController {

  final GeolocationService gl = Get.find<GeolocationService>();
  final DatabaseService db = Get.find<DatabaseService>();

  StreamSubscription<ServiceStatus>? listener;
  var permissionGranted = false;
  var loadingLocation = false;

  @override
  void onInit() async {
    listener = Geolocator.getServiceStatusStream().listen(onStatusChanged);
    permissionGranted = await gl.isPermissionGranted();
    update();
    if(permissionGranted) onContinueTap();
    super.onInit();
  }

  void onGrantPermissionTap() async {
    var hasPermission = await gl.getPermission();
    permissionGranted = hasPermission;
    if(permissionGranted) onContinueTap();
  }

  void onContinueTap() async {
    try{
      var position = await gl.determinePosition(forceGivePermission: true, forceTurnOnLocation: true);
      if(position != null) {
        // Call your user location API here
      }
      await db.putIsLocationScreenShown(true);

      try{ listener?.cancel(); }catch(e){}

      Get.offAllNamed(AppRoutes.userDashBoard);
    }catch(error){
      showToast(message: error.toString());
    }
  }

  void onStatusChanged(ServiceStatus status) async {
    if(status == ServiceStatus.enabled) {
      await gl.sendLocationWithApi();
    }
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }

  @override
  void onClose() {
    listener?.cancel();
    super.onClose();
  }
}