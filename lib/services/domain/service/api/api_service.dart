part of 'api_import.dart';

class ApiService {
  Future<ApiService> init() async {
    dio = createDio();
    externalDio = createDio(isExternal: true);

    print('api service initialize');
    return this;
  }

  late Dio dio;
  late Dio externalDio;

  // var serverUrl = 'http://campus-development.saplynx.com';
  var serverUrl = ApiEndpoint.baseUrl;

  // List<String> allowedSHAFingerprints = ['20:12:97:49:15:CA:8F:11:F8:01:36:A2:C8:A9:8E:E0:05:DE:D0:61:A2:98:72:10:13:29:51:15:CE:92:7C:27'];
  // List<String> allowedSHAFingerprints = ['43:D0:56:9D:12:9C:27:32:F5:55:30:9B:F3:3A:19:CA:DB:73:83:D9:B2:C4:E8:50:C0:0D:7A:A4:6D:C6:7C:C1'];

  Dio createDio({bool isExternal = false}) {

    var customServerURL = gt.Get.find<DatabaseService>().customServerURL;
    Dio dio;
    if (isExternal) {
      dio = Dio(BaseOptions(baseUrl: isExternal ? '' : customServerURL ?? serverUrl));
    } else {
      dio = Dio(BaseOptions(baseUrl: isExternal ? '' : customServerURL ?? serverUrl));
      //..interceptors.add(CertificatePinningInterceptor(allowedSHAFingerprints: allowedSHAFingerprints));
    }
    // ..interceptors.add(DioCacheInterceptor(options: options))
    dio.interceptors.addAll({
      AppInterceptors(isExternal: isExternal),
    });
    return dio;
  }
}
