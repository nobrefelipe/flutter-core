// core/ui/webview/app_webview.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Reusable WebView widget for displaying web content.
/// Used by AppNavigator for NavType.webpage navigation.
///
/// Usage:
/// ```dart
/// AppWebView(
///   url: 'https://example.com',
///   title: 'Help Center',
/// )
/// ```
class AppWebView extends StatefulWidget {
  final String url;
  final String? title;

  const AppWebView({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Web Page'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
