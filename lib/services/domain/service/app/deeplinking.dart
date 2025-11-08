import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:plex_user/routes/appRoutes.dart';

final AppLinks _appLinks = AppLinks();
StreamSubscription<Uri?>? _sub;

void initDeepLinks() {
  debugPrint('[DeepLink] Initializing App Links listener...');

  _sub = _appLinks.uriLinkStream.listen(
        (Uri? uri) {
      debugPrint('[DeepLink] URI received: $uri');
      if (uri != null) _handleUri(uri);
    },
    onError: (err) {
      debugPrint('[DeepLink] Error in stream: $err');
    },
    onDone: () {
      debugPrint('[DeepLink] Stream closed.');
    },
  );

  // Optional — test if AppLinks instance is active
  Future.delayed(Duration(seconds: 1), () {
    debugPrint('[DeepLink] Listener active ✅ Waiting for incoming links...');
  });
}

void disposeDeepLinks() {
  debugPrint('[DeepLink] Disposing listener...');
  _sub?.cancel();
  _sub = null;
}

void _handleUri(Uri uri) {
  final path = uri.path;
  final query = uri.queryParameters;
  debugPrint('[DeepLink] Handling URI path: $path');
  debugPrint('[DeepLink] Query params: $query');

  if (path.contains('/reset-password')) {
    final token = uri.queryParameters['token'];
    if (token != null && token.isNotEmpty) {
      debugPrint('[DeepLink] Navigating to /reset-password with token: $token');
      Get.toNamed(AppRoutes.resetPassword, arguments: {'token': token});
    } else {
      debugPrint('[DeepLink] Missing or empty token parameter ❌');
    }
  } else {
    debugPrint('[DeepLink] No matching route for $path');
  }
}
