import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../routes/appRoutes.dart';

class PayPalWebView extends StatefulWidget {
  final String url;
  const PayPalWebView({required this.url, Key? key}) : super(key: key);

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController _controller;

  final List<String> successPaths = ['/paypal/success', '/paypal/return'];
  final List<String> cancelPaths = ['/paypal/cancel', '/paypal/cancelled'];

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            final path = uri.path.toLowerCase();

            if (successPaths.any((p) => path.contains(p))) {
              Future.microtask(() {
                Get.offAllNamed(AppRoutes.bookingConfirm);
              });
              return NavigationDecision.prevent;
            } else if (cancelPaths.any((p) => path.contains(p))) {
              Future.microtask(() {
                Get.back(result: 'cancel');
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) => debugPrint('Page finished: $url'),
          onWebResourceError: (err) => debugPrint('WebView error: ${err.description}'),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with PayPal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(result: 'cancel'),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
