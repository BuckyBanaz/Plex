part of 'api_import.dart';

/// ApiService: creates single Dio instances, stores token in-memory to avoid repeated DB reads.
class ApiService {
  Future<ApiService> init() async {
    dio = createDio();
    externalDio = createDio(isExternal: true);
    return this;
  }

  late Dio dio;
  late Dio externalDio;
  var serverUrl = ApiEndpoint.baseUrl;

  Dio createDio({bool isExternal = false}) {
    // Use custom server URL if provided in database service (fast get without prints)
    final customServerURL = gt.Get.isRegistered<DatabaseService>()
        ? gt.Get.find<DatabaseService>().customServerURL
        : null;

    final base = (isExternal ? '' : (customServerURL ?? serverUrl));
    final options = BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 15000),
      sendTimeout: const Duration(milliseconds: 10000),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status >= 200 && status < 600,
    );

    final _dio = Dio(options);

    // Attach minimal interceptor (no heavy operations, no prints)
    _dio.interceptors.add(AppInterceptors(isExternal: isExternal));
    return _dio;
  }
}

