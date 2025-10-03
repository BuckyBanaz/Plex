part of 'api_import.dart';

class AppInterceptors extends Interceptor {
  //  AppInterceptors({required appService}): _appService= appService;
  //  AppInterceptors({required appService}): _appService= appService;

  final bool isExternal;
  AppInterceptors({this.isExternal = false});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    printInfo(info: '\nRequest type: ${options.method} API request: ${options.uri}');
    printInfo(info: "\nAPI headers: ${options.headers}");
    printInfo(info: "\nAPI data: ${options.data}");

    if (isExternal) return handler.next(options);
    var accessToken = gt.Get.find<DatabaseService>().accessToken;
    bool? skipToken = options.extra['skipToken'];
    debugPrint(accessToken);
    if (accessToken != null) {
      if (skipToken ?? true) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
        'Api Error: ${err.requestOptions.method} ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('Error Message:  ${err.response?.statusMessage}');
    switch (err.type) {
      case DioExceptionType.sendTimeout:
        throw DefaultException(err.requestOptions, err,
            msg: ErrorStrings.timeOut);
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(err.requestOptions);
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(err.requestOptions, err);
          case 401:
            throw UnauthorizedException(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions);
          case 409:
            throw ConflictException(err.requestOptions);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
          case 504:
            throw DeadlineExceededException(err.requestOptions);
          case 406:
            throw OtpTimeError(err.requestOptions, err);
          case 429:
            throw OtpTimeError(err.requestOptions, err);
        }
        break;
      case DioExceptionType.cancel:
        throw DefaultException(err.requestOptions, err,
            msg: ErrorStrings.cancel);

      case DioExceptionType.connectionTimeout:
        throw DefaultException(err.requestOptions, err,
            msg: ErrorStrings.timeOut);

      case DioExceptionType.badCertificate:
        throw DefaultException(err.requestOptions, err);

      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(err.requestOptions);

      case DioExceptionType.unknown:
        throw DefaultException(err.requestOptions, err);
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('Request type: ${response.requestOptions.method}');
    debugPrint(
        'Request Success: ${response.statusCode}\ndata: ${response.data}');
    if (response.statusCode.toString().startsWith('2')) {
      response.extra['done'] = true;
    }
    super.onResponse(response, handler);
  }
}

// class BadRequestException extends DioException {
//   @override
//   // ignore: overridden_fields
//   final DioException error;
//   BadRequestException(RequestOptions r, this.error) : super(requestOptions: r);
//   @override
//   String toString() {
//     String message = '';
//     try {
//       message = error.response!.data['message'];
//     } catch (e) {
//       message = 'Invalid request';
//     }
//     return message;
//   }
// }
//
// class InternalServerErrorException extends DioException {
//   InternalServerErrorException(RequestOptions r) : super(requestOptions: r);
//   @override
//   String toString() {
//     const message = ErrorStrings.internalServerError;
//     // debugPrint(errorToString(requestOptions, message));
//     return message;
//   }
// }
//
// class ConflictException extends DioException {
//   ConflictException(RequestOptions r) : super(requestOptions: r);
//   @override
//   String toString() {
//     const message = ErrorStrings.conflict;
//     return message;
//   }
// }
//
// class UnauthorizedException extends DioException {
//   UnauthorizedException(
//       RequestOptions r,
//       ) : super(requestOptions: r);
//   @override
//   String toString() {
//     const message = ErrorStrings.unAuthorized;
//     logout();
//     return message;
//   }
// }
//
// void logout() async {
//   try {
//     await sl.get<DatabaseService>().clearPreference();
//     sl.reset();
//     initializeServices();
//     // ignore: use_build_context_synchronously
//     Phoenix.rebirth(TempContext.context);
//     showToast(message: 'Authentication Failed.');
//   } catch (e) {
//     debugPrint(e.toString());
//     showToast(
//         message:
//         "Authentication Failed. Please restart the app and try again.");
//   }
// }
//
// void showToast({required String message}) {
// }
//
// class NotFoundException extends DioException {
//   NotFoundException(RequestOptions r) : super(requestOptions: r);
//   @override
//   String toString() {
//     const message = ErrorStrings.noFoundError;
//     return message;
//   }
// }
//
// class NoInternetConnectionException extends DioException {
//   NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);
//   @override
//   String toString() {
//     const message = ErrorStrings.connectionError;
//     return message;
//   }
// }
//
// class DeadlineExceededException extends DioException {
//   DeadlineExceededException(RequestOptions r) : super(requestOptions: r);
//   @override
//   String toString() {
//     const message = ErrorStrings.timeOut;
//     return message;
//   }
// }
//
// class OtpTimeError extends DioException {
//   @override
//   // ignore: overridden_fields
//   final DioException error;
//   OtpTimeError(RequestOptions r, this.error) : super(requestOptions: r);
//
//   @override
//   String toString() {
//     String message = '';
//     try {
//       message = error.response?.data['message'];
//     } catch (e) {
//       message = ErrorStrings.otpError;
//     }
//     return message;
//   }
// }
//
// class DefaultException extends DioException {
//   @override
//   // ignore: overridden_fields
//   final DioException error;
//   final String? msg;
//   DefaultException(RequestOptions r, this.error, {this.msg})
//       : super(requestOptions: r);
//
//   @override
//   String toString() {
//     // error.error!.message!;
//     String message = '';
//     try {
//       message = error.response?.data['message'] ??
//           msg ??
//           ErrorStrings.internalServerError;
//     } catch (e) {
//       message = ErrorStrings.internalServerError;
//     }
//     debugPrint(errorToString(requestOptions, message));
//     return message;
//   }
// }
//
// String errorToString(RequestOptions ro, String message) {
//   return '\nAPI Error:${ro.method} ${ro.uri}\nMessage: $message';
// }
