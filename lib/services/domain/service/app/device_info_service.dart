part of 'app_service_imports.dart';

class DeviceInfoService {
  late MessagingService ms;
  AndroidDeviceInfo? androidInfo;
  IosDeviceInfo? iosInfo;
  late PackageInfo packageInfo;

  Future<DeviceInfoService> init() async {
    // Try to reuse the messaging service registered by AppService.
    try {
      if (Get.isRegistered<MessagingService>()) {
        ms = Get.find<MessagingService>();
      } else {
        // fallback: create a new messaging service (not ideal, but safe)
        ms = MessagingService();
        await ms.init();
      }
    } catch (e) {
      // Fallback to a fresh instance if anything goes wrong
      ms = MessagingService();
      await ms.init();
    }

    packageInfo = await PackageInfo.fromPlatform();
    if (defaultTargetPlatform == TargetPlatform.android) {
      androidInfo = await DeviceInfoPlugin().androidInfo;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      iosInfo = await DeviceInfoPlugin().iosInfo;
    }
    debugPrint('DeviceInfo service is initialized');
    return this;
  }

  Future<DeviceInfoModel> getDeviceInfo() async {
    String firebaseToken = await ms.getFirebaseToken() ?? '';
    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String appVersion = '$appName (version $version build $buildNumber)';

    String deviceId = '';
    String deviceModel = '';
    String deviceOs = '';

    if (defaultTargetPlatform == TargetPlatform.android) {
      deviceId = androidInfo?.id ?? '';
      deviceModel = androidInfo?.brand ?? '';
      deviceOs = androidInfo?.version.release ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      deviceId = iosInfo?.identifierForVendor ?? '';
      deviceModel = iosInfo?.model ?? '';
      deviceOs = iosInfo?.systemName ?? iosInfo?.systemVersion ?? '';
    }

    return DeviceInfoModel(
      deviceId: deviceId,
      firebaseToken: firebaseToken,
      deviceModel: deviceModel,
      deviceOs: deviceOs,
      appVersion: appVersion,
    );
  }
}