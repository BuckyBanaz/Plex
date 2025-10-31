part of 'app_service_imports.dart';

class DeviceInfoService {
  AndroidDeviceInfo? androidInfo;
  IosDeviceInfo? iosInfo;
  late PackageInfo packageInfo;

  Future<DeviceInfoService> init() async {
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
    String deviceId, deviceModel, deviceOs, appVersion = '';

    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    appVersion = '$appName (version $version build $buildNumber)';

    if (defaultTargetPlatform == TargetPlatform.android) {
      deviceId = androidInfo?.id ?? '';
      deviceModel = androidInfo?.brand ?? '';
      deviceOs = androidInfo?.version.release ?? '';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      deviceId = iosInfo?.identifierForVendor ?? '';
      deviceModel = iosInfo?.model ?? '';
      deviceOs = iosInfo?.systemName ?? iosInfo?.systemVersion ?? '';
    } else {
      deviceId = '';
      deviceModel = '';
      deviceOs = '';
    }

    return DeviceInfoModel(
      deviceId: deviceId,
      deviceModel: deviceModel,
      deviceOs: deviceOs,
      appVersion: appVersion,
    );
  }
}
