part of 'api_import.dart';

/// ApiService: creates single Dio instances, stores token in-memory to avoid repeated DB reads.
// class ApiService {
//   Future<ApiService> init() async {
//     dio = createDio();
//     externalDio = createDio(isExternal: true);
//     return this;
//   }
//
//   late Dio dio;
//   late Dio externalDio;
//   var serverUrl = ApiEndpoint.baseUrl;
//
//   Dio createDio({bool isExternal = false}) {
//     // Use custom server URL if provided in database service (fast get without prints)
//     final customServerURL = gt.Get.isRegistered<DatabaseService>()
//         ? gt.Get.find<DatabaseService>().customServerURL
//         : null;
//
//     final base = (isExternal ? '' : (customServerURL ?? serverUrl));
//     final options = BaseOptions(
//       baseUrl: base,
//       connectTimeout: const Duration(milliseconds: 10000),
//       receiveTimeout: const Duration(milliseconds: 15000),
//       sendTimeout: const Duration(milliseconds: 10000),
//       responseType: ResponseType.json,
//       validateStatus: (status) => status != null && status >= 200 && status < 600,
//     );
//
//     final _dio = Dio(options);
//
//     // Attach minimal interceptor (no heavy operations, no prints)
//     _dio.interceptors.add(AppInterceptors(isExternal: isExternal));
//     return _dio;
//   }
// }
//
// class ApiService {
//   Future<ApiService> init() async {
//     dio = createDio();
//     externalDio = createDio(isExternal: true);
//     return this;
//   }
//
//   late Dio dio;
//   late Dio externalDio;
//   var serverUrl = ApiEndpoint.baseUrl;
//
//   Dio createDio({bool isExternal = false}) {
//     final customServerURL = gt.Get.isRegistered<DatabaseService>()
//         ? gt.Get.find<DatabaseService>().customServerURL
//         : null;
//
//     final base = (isExternal ? '' : (customServerURL ?? serverUrl));
//     final options = BaseOptions(
//       baseUrl: base,
//       connectTimeout: const Duration(milliseconds: 10000),
//       receiveTimeout: const Duration(milliseconds: 15000),
//       sendTimeout: const Duration(milliseconds: 10000),
//       responseType: ResponseType.json,
//       validateStatus: (status) => status != null && status >= 200 && status < 600,
//     );
//
//     final _dio = Dio(options);
//
//     // pass the dio instance to AppInterceptors so it can retry requests
//     _dio.interceptors.add(AppInterceptors(dio: _dio, isExternal: isExternal));
//     return _dio;
//   }
// }
class ApiService {
  Future<ApiService> init() async {
    dio = createDio();
    externalDio = createDio(isExternal: true);

    print('api service initialize');
    return this;
  }

  late Dio dio;
  late Dio externalDio;

  var serverUrl = ApiEndpoint.baseUrl;

  // List<String> allowedSHAFingerprints = ['20:12:97:49:15:CA:8F:11:F8:01:36:A2:C8:A9:8E:E0:05:DE:D0:61:A2:98:72:10:13:29:51:15:CE:92:7C:27'];
  // List<String> allowedSHAFingerprints = ['43:D0:56:9D:12:9C:27:32:F5:55:30:9B:F3:3A:19:CA:DB:73:83:D9:B2:C4:E8:50:C0:0D:7A:A4:6D:C6:7C:C1'];

  Dio createDio({bool isExternal = false}) {
    var customServerURL = gt.Get.find<DatabaseService>().customServerURL;
    Dio dio;

    final baseOptions = BaseOptions(
      baseUrl: isExternal ? '' : customServerURL ?? serverUrl,

      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
    );

    if (isExternal) {
      dio = Dio(baseOptions);
    } else {
      dio = Dio(baseOptions);
      //..interceptors.add(CertificatePinningInterceptor(allowedSHAFingerprints: allowedSHAFingerprints));
    }

    dio.interceptors.addAll({
      AppInterceptors(dio: dio, isExternal: isExternal)
    });
    return dio;
  }
}