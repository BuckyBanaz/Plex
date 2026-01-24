part of 'api_import.dart';

/// Bad request parameter exception - [400]
class BadRequestException extends DioException {
  @override
  // ignore: overridden_fields
  final DioException error;
  BadRequestException(RequestOptions r, this.error) : super(requestOptions: r);
  @override
  String toString() {
    String message = '';
    try {
      message = error.response!.data['message'];
    } catch (e) {
      message = 'Invalid request';
    }
    return message;
  }
}

/// 500 status code exception - [500]
class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    const message = ErrorStrings.internalServerError;
    return message;
  }
}

/// Conflict Exception - [409]
class ConflictException extends DioException {
  final DioException? error;
  ConflictException(RequestOptions r, [this.error])
      : super(
          requestOptions: r,
          response: error?.response,
          type: error?.type ?? DioExceptionType.unknown,
          error: error?.error,
        );
  @override
  String toString() {
    String message = '';
    try {
      message = error?.response?.data['message'] ?? ErrorStrings.conflict;
    } catch (e) {
      message = ErrorStrings.conflict;
    }
    return message;
  }
}

/// Wrong token exception (token timeout, accessing not permission data ) - [401]
class UnauthorizedException extends DioException {
  UnauthorizedException(
      RequestOptions r,
      ) : super(requestOptions: r);

  @override
  String toString() {
    const message = ErrorStrings.unAuthorized;
    logout();
    return message;
  }
}

/// logout function when user get unauthorized exception
void logout() async {
  try {
    final dbService = Get.find<DatabaseService>();

    await dbService.clearPreference();

    // Get.reset();
    // await Get.putAsync(() => AppService().init());
    Get.offAllNamed(AppRoutes.splash);

  } catch (e) {
    debugPrint("Logout error: $e");

    try {
      // Get.reset();
      // await Get.putAsync(() => AppService().init());
      Get.offAllNamed(AppRoutes.splash);
    } catch (e2) {
      debugPrint("Failed to force restart: $e2");
    }

    showToast(
        message: "Authentication Failed. Please restart the app and try again.");
  }
}

/// Route not found exception  - [404]
class NotFoundException extends DioException {
  NotFoundException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    const message = ErrorStrings.noFoundError;
    return message;
  }
}

/// No internet connection - [dio]
class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    const message = ErrorStrings.connectionError;
    return message;
  }
}

/// request time out connection to server - [504]
class DeadlineExceededException extends DioException {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);
  @override
  String toString() {
    const message = ErrorStrings.timeOut;
    return message;
  }
}

/// Exception for wrong otp or timeout - [406, 429]
class OtpTimeError extends DioException {
  @override
  // ignore: overridden_fields
  final DioException error;
  OtpTimeError(RequestOptions r, this.error) : super(requestOptions: r);

  @override
  String toString() {
    String message = '';
    try {
      message = error.response?.data['message'];
    } catch (e) {
      message = ErrorStrings.otpError;
    }
    return message;
  }
}

/// Default exception to handel other status codes
class DefaultException extends DioException {
  @override
  // ignore: overridden_fields
  final DioException error;
  final String? msg;
  DefaultException(RequestOptions r, this.error, {this.msg})
      : super(requestOptions: r);

  @override
  String toString() {
    String message = '';
    try {
      message = error.response?.data['message'] ??
          msg ??
          ErrorStrings.internalServerError;
    } catch (e) {
      message = ErrorStrings.internalServerError;
    }
    return message;
  }
}

/// method to print error
String errorToString(RequestOptions ro, String message) {
  return '\nAPI Error:${ro.method} ${ro.uri}\nMessage: $message';
}