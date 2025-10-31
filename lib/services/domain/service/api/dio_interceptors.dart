part of 'api_import.dart';

// ---------- FILE 1: app_interceptors.dart ----------

class AppInterceptors extends Interceptor {
  final Dio dio;
  final bool isExternal;

  AppInterceptors({required this.dio, this.isExternal = false});

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (isExternal) return handler.next(options);

    printInfo(
      info:
      "\nAPI headers: ${options.headers} \nAPI data: ${options.data} \nAPI request: ${options.uri}",
    );

    var accessToken = gt.Get.find<DatabaseService>().accessToken;

    // This logic is correct — skip adding token if 'skipToken' flag is true.
    final bool skipToken = options.extra['skipToken'] == true;

    if (accessToken != null && accessToken.isNotEmpty && !skipToken) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    printInfo(
      info:
      '\nRequest type: ${response.requestOptions.method} \nRequest Success: ${response.statusCode}\nData: ${response.data}',
    );

    if (response.statusCode != null &&
        response.statusCode.toString().startsWith('2')) {
      response.extra['done'] = true;
    }

    super.onResponse(response, handler);
  }

  /// Handles token refresh logic when a 401 Unauthorized error occurs.
  /// Automatically retries the original request once after a successful token refresh.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint(
      'API Error: ${err.requestOptions.method} ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    debugPrint('Error Data: ${err.response?.data}');
    debugPrint('Error Message: ${err.response?.statusMessage}');

    if (isExternal) return handler.next(err);

    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    final alreadyRetried = requestOptions.extra['retried'] == true;
    // Check if the current request is itself a refresh token call.
    final isRefreshCall = requestOptions.extra['isRefreshCall'] == true;

    // -----------------------------------------------------------------
    // SCENARIO 1: Refresh token call itself failed.
    // Let this propagate to the AuthRepository catch block.
    // -----------------------------------------------------------------
    if (isRefreshCall) {
      debugPrint(
          'Refresh token request failed. Forwarding error to AuthRepository catch block.');
      return handler.next(err);
    }

    // -----------------------------------------------------------------
    // SCENARIO 2: A normal API call (e.g., /location) returned 401.
    // Attempt to refresh the access token.
    // -----------------------------------------------------------------
    if (statusCode == 401 && !alreadyRetried) {
      debugPrint('Received 401. Attempting token refresh...');

      final authRepo = Get.find<AuthRepository>();
      // The refreshToken() method will return a RefreshStatus enum.
      final RefreshStatus refreshStatus = await authRepo.refreshToken();

      switch (refreshStatus) {
      // --- CASE 1: SUCCESS ---
        case RefreshStatus.success:
          debugPrint('Token refresh successful. Retrying original request...');
          final newToken = Get.find<DatabaseService>().accessToken;
          if (newToken != null && newToken.isNotEmpty) {
            // Mark request as retried.
            requestOptions.extra['retried'] = true;
            requestOptions.headers['Authorization'] = 'Bearer $newToken';

            // Retry the original request.
            final clonedRequest = Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
              responseType: requestOptions.responseType,
              followRedirects: requestOptions.followRedirects,
              validateStatus: requestOptions.validateStatus,
              receiveDataWhenStatusError:
              requestOptions.receiveDataWhenStatusError,
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
          }
          // No new token found — force logout.
          return handler.reject(UnauthorizedException(requestOptions));

      // --- CASE 2: REFRESH TOKEN INVALID ---
        case RefreshStatus.failedInvalidToken:
          debugPrint('Refresh token is invalid. Logging out user.');
          return handler.reject(UnauthorizedException(requestOptions));

      // --- CASE 3: OTHER FAILURE (Network, 500, etc.) ---
        case RefreshStatus.failedOther:
          debugPrint(
              'Token refresh failed due to network/server error. Returning original failure.');
          // Do not log out, just forward the original error.
          return handler.next(err);
      }
    }

    // -----------------------------------------------------------------
    // SCENARIO 4: If the request was already retried and still returned 401,
    // logout the user.
    // -----------------------------------------------------------------
    if (statusCode == 401) {
      debugPrint('Already retried but still received 401. Logging out.');
      return handler.reject(UnauthorizedException(requestOptions));
    }

    // -----------------------------------------------------------------
    // Handle other status codes (400, 404, 500, etc.)
    // -----------------------------------------------------------------
    switch (err.type) {
      case DioExceptionType.sendTimeout:
        return handler.reject(
          DioException(
            requestOptions: requestOptions,
            error: ErrorStrings.timeOut,
          ),
        );
      case DioExceptionType.receiveTimeout:
        return handler.reject(DeadlineExceededException(requestOptions));
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            return handler.reject(BadRequestException(requestOptions, err));
        // 401 handled already
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
        break; // Required to prevent fall-through
      case DioExceptionType.cancel:
        return handler.reject(
          DefaultException(requestOptions, err, msg: ErrorStrings.cancel),
        );
      case DioExceptionType.connectionTimeout:
        return handler.reject(
          DefaultException(requestOptions, err, msg: ErrorStrings.timeOut),
        );
      case DioExceptionType.badCertificate:
        return handler.reject(DefaultException(requestOptions, err));
      case DioExceptionType.connectionError:
        return handler.reject(NoInternetConnectionException(requestOptions));
      case DioExceptionType.unknown:
        return handler.reject(DefaultException(requestOptions, err));
    }

    // Fallback: Forward the original error.
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
