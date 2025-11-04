part of 'app_service_imports.dart';


class AppService extends GetxService {
  Future<AppService> init() async {
    await initiateServices();
    return this;
  }

  Future<void> initiateServices() async {
    await Future.wait([
     Get.putAsync(() => DatabaseService().init()),
      Get.putAsync(() => LocaleController().init()),
      Get.putAsync(() => DeviceInfoService().init()),


    ]);

    await Get.putAsync(() => ApiService().init());

    await Future.wait([
      Get.putAsync(() => GeolocationService().init())
    ]);
     await initializeApiServices(Get.find<ApiService>());
     await initializeRepositories();

  }

  Future<void> initializeApiServices(ApiService apiService) async{

    /// Initialize and put the FileAPI
    // Get.put( FileAPI(dio: apiService.dio, externalDio: apiService.externalDio));

    /// Initialize and put the AuthApi
    Get.put( AuthApi(apiService.dio));

    /// Initialize and put the UserApi
    Get.put( UserApi(apiService.dio));

    /// Initialize and put the MapApi
    Get.put( MapApi());

    /// Initialize and put the ShipmentApi
    Get.put( ShipmentApi(apiService.dio));


//
//    /// Initialize and put the SearchApi
//    Get.put( SearchApi(apiService.dio));
//
//    /// Initialize and put the UserApi
//    Get.put( UserApi(apiService.dio));
//
//    /// Initialize and put the NotificationAPI
//    Get.put( NotificationAPI(apiService.dio));
//
//    /// Initialize and put the TrackingApi
//    Get.put( TrackingApi(apiService.dio));
//


  }
}
