part of 'api_import.dart';

// class AppInterceptors extends Interceptor {
//   //  AppInterceptors({required appService}): _appService= appService;
//   //  AppInterceptors({required appService}): _appService= appService;
//
//   final bool isExternal;
//   AppInterceptors({this.isExternal = false});
//
//   @override
//   void onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     // printInfo(info: '\nRequest type: ${options.method} API request: ${options.uri}');
//     // printInfo(info: "\nAPI headers: ${options.headers}");
//     // printInfo(info: "\nAPI data: ${options.data}");
//
//     if (isExternal) return handler.next(options);
//     var accessToken = gt.Get.find<DatabaseService>().accessToken;
//     bool? skipToken = options.extra['skipToken'];
//     debugPrint(accessToken);
//     if (accessToken != null) {
//       if (skipToken ?? true) {
//         options.headers['Authorization'] = 'Bearer $accessToken';
//       }
//     }
//     return handler.next(options);
//   }
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     debugPrint(
//         'Api Error: ${err.requestOptions.method} ${err.response?.statusCode} ${err.requestOptions.uri}');
//     debugPrint('Error Message:  ${err.response?.statusMessage}');
//     switch (err.type) {
//       case DioExceptionType.sendTimeout:
//         throw DefaultException(err.requestOptions, err,
//             msg: ErrorStrings.timeOut);
//       case DioExceptionType.receiveTimeout:
//         throw DeadlineExceededException(err.requestOptions);
//       case DioExceptionType.badResponse:
//         switch (err.response?.statusCode) {
//           case 400:
//             throw BadRequestException(err.requestOptions, err);
//           case 401:
//             throw UnauthorizedException(err.requestOptions);
//           case 404:
//             throw NotFoundException(err.requestOptions);
//           case 409:
//             throw ConflictException(err.requestOptions);
//           case 500:
//             throw InternalServerErrorException(err.requestOptions);
//           case 504:
//             throw DeadlineExceededException(err.requestOptions);
//           case 406:
//             throw OtpTimeError(err.requestOptions, err);
//           case 429:
//             throw OtpTimeError(err.requestOptions, err);
//         }
//         break;
//       case DioExceptionType.cancel:
//         throw DefaultException(err.requestOptions, err,
//             msg: ErrorStrings.cancel);
//
//       case DioExceptionType.connectionTimeout:
//         throw DefaultException(err.requestOptions, err,
//             msg: ErrorStrings.timeOut);
//
//       case DioExceptionType.badCertificate:
//         throw DefaultException(err.requestOptions, err);
//
//       case DioExceptionType.connectionError:
//         throw NoInternetConnectionException(err.requestOptions);
//
//       case DioExceptionType.unknown:
//         throw DefaultException(err.requestOptions, err);
//     }
//     return handler.next(err);
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     debugPrint('Request type: ${response.requestOptions.method}');
//     debugPrint(
//         'Request Success: ${response.statusCode}\ndata: ${response.data}');
//     if (response.statusCode.toString().startsWith('2')) {
//       response.extra['done'] = true;
//     }
//     super.onResponse(response, handler);
//   }
// }




class AppInterceptors extends Interceptor {
  final Dio dio;
  final bool isExternal;

  AppInterceptors({required this.dio, this.isExternal = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (isExternal) return handler.next(options);
    // printInfo(info: '\nRequest type: ${options.method} API request: ${options.uri}');
    printInfo(info: "\nAPI headers: ${options.headers}");
    printInfo(info: "\nAPI data: ${options.data}");
    printInfo( info: '\nAPI request: ${options.uri}');
    var accessToken = gt.Get.find<DatabaseService>().accessToken;
    bool? skipToken = options.extra['skipToken'];
    // note: your original code used `if (skipToken ?? true)` to add token — keep same semantics
    if (accessToken != null) {
      if (skipToken ?? true) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('Request type: ${response.requestOptions.method}');
    debugPrint(
        'Request Success: ${response.statusCode}\ndata: ${response.data}');
    if (response.statusCode != null && response.statusCode.toString().startsWith('2')) {
      response.extra['done'] = true;
    }
    super.onResponse(response, handler);
  }

  /// onError will attempt a token refresh when we get a 401 and retry the original request once.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint(
        'Api Error: ${err.requestOptions.method} ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('Error Message:  ${err.response?.statusMessage}');

    // If this interceptor is for external requests, don't try refresh
    if (isExternal) return handler.next(err);

    // If it's a 401 unauthorized from server, try refresh token flow
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    // Prevent infinite retry loops
    final alreadyRetried = requestOptions.extra['retried'] == true;

    if (statusCode == 401 && !alreadyRetried) {
      try {
        final authRepo = Get.find<AuthRepository>();
        final refreshed = await authRepo.refreshToken();

        if (refreshed) {
          // get the new token from DatabaseService
          final newToken = Get.find<DatabaseService>().accessToken;
          if (newToken != null && newToken.isNotEmpty) {
            // mark as retried
            requestOptions.extra['retried'] = true;

            // update Authorization header and retry original request
            requestOptions.headers['Authorization'] = 'Bearer $newToken';

            // create a new request using the dio instance tied to this interceptor
            final clonedRequest = Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
              responseType: requestOptions.responseType,
              followRedirects: requestOptions.followRedirects,
              validateStatus: requestOptions.validateStatus,
              receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
              extra: requestOptions.extra,
              contentType: requestOptions.contentType,
            );

            final response = await dio.request<dynamic>(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: clonedRequest,
              cancelToken: requestOptions.cancelToken,
              onReceiveProgress: requestOptions.onReceiveProgress,
              onSendProgress: requestOptions.onSendProgress,
            );

            return handler.resolve(response);
          } else {
            // refresh succeeded but token missing — treat as unauthorized
            return handler.reject(DioException(
                requestOptions: requestOptions,
                error: 'Token refresh returned no token'));
          }
        } else {
          // refresh failed
          return handler.reject(DioException(
              requestOptions: requestOptions, error: 'Unable to refresh token'));
        }
      } catch (e) {
        debugPrint('Token refresh attempt failed: $e');
        // If refresh failed — force logout behavior from your UnauthorizedException
        return handler.reject(UnauthorizedException(requestOptions));
      }
    }

    // If not 401 or already retried — map other errors to appropriate exceptions
    switch (err.type) {
      case DioExceptionType.sendTimeout:
        return handler.reject(DioException(requestOptions: requestOptions, error: ErrorStrings.timeOut));
      case DioExceptionType.receiveTimeout:
        return handler.reject(DeadlineExceededException(requestOptions));
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            return handler.reject(BadRequestException(requestOptions, err));
          case 401:
            return handler.reject(UnauthorizedException(requestOptions));
          case 404:
            return handler.reject(NotFoundException(requestOptions));
          case 409:
            return handler.reject(ConflictException(requestOptions));
          case 500:
            return handler.reject(InternalServerErrorException(requestOptions));
          case 504:
            return handler.reject(DeadlineExceededException(requestOptions));
          case 406:
          case 429:
            return handler.reject(OtpTimeError(requestOptions, err));
        }
        break;
      case DioExceptionType.cancel:
        return handler.reject(DefaultException(requestOptions, err, msg: ErrorStrings.cancel));
      case DioExceptionType.connectionTimeout:
        return handler.reject(DefaultException(requestOptions, err, msg: ErrorStrings.timeOut));
      case DioExceptionType.badCertificate:
        return handler.reject(DefaultException(requestOptions, err));
      case DioExceptionType.connectionError:
        return handler.reject(NoInternetConnectionException(requestOptions));
      case DioExceptionType.unknown:
        return handler.reject(DefaultException(requestOptions, err));
    }

    // fallback: forward the original error
    return handler.next(err);
  }
}




// class AppInterceptors extends Interceptor {
//   final bool isExternal;
//   AppInterceptors({this.isExternal = false});
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     if (isExternal) {
//       handler.next(options);
//       return;
//     }
//     // printInfo(info: '\nRequest type: ${options.method}'' API request: ${options.uri}');
//     printInfo( info: '\nAPI request: ${options.uri}');
//     // printInfo(info: "\nAPI headers: ${options.headers}");
//     printInfo(info: "\nAPI data: ${options.data}");
//
//     // cheap header insertion only
//     try {
//       final dbExists = gt.Get.isRegistered<DatabaseService>();
//       if (dbExists) {
//         final token = gt.Get.find<DatabaseService>().accessToken;
//         final skipToken = options.extra['skipToken'] ?? false;
//         if (token != null && !skipToken) {
//           options.headers['Authorization'] = 'Bearer $token';
//         }
//       }
//     } catch (_) {
//       // swallow - avoid blocking the request
//     }
//
//     handler.next(options);
//   }
//
//   @override
//   void onError(DioError err, ErrorInterceptorHandler handler) {
//     // Map common status codes quickly; let repository handle user feedback
//     switch (err.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         handler.reject(err);
//         return;
//       case DioExceptionType.badResponse:
//       // pass-through, repository will interpret
//         handler.next(err);
//         return;
//       default:
//         handler.next(err);
//         return;
//     }
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//         debugPrint('Request type: ${response.requestOptions.method}');
//     debugPrint(
//         'Request Success: ${response.statusCode}\ndata: ${response.data}');
//
//     handler.next(response);
//   }
// }
