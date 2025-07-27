import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Conditional imports
late WebViewWrapper webViewWrapper;

void setupWebView() {
  if (kIsWeb) {
    // Web implementation

    webViewWrapper = WebWebView();
  } else {
    // Mobile implementation

    webViewWrapper = MobileWebView();
  }
}

abstract class WebViewWrapper {
  Widget buildWebView(String url);
}

// Mobile implementation
class MobileWebView implements WebViewWrapper {
  @override
  Widget buildWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
    return WebViewWidget(controller: controller);
  }
}

// Web implementation
class WebWebView implements WebViewWrapper {
  @override
  Widget buildWebView(String url) {
    try {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      );
    } catch (e) {
      // Fallback if iframe embedding fails
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Content couldn't be embedded"),
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(url)),
              child: const Text("Open in Browser"),
            ),
          ],
        ),
      );
    }
  }
}

class CumulativeReportPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CumulativeReportPage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<CumulativeReportPage> createState() => _CumulativeReportPageState();
}

class _CumulativeReportPageState extends State<CumulativeReportPage> {
  @override
  void initState() {
    super.initState();
    setupWebView();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: webViewWrapper.buildWebView(
        'https://creativecollege.in/MIS/MIS/Notes%20And%20Assignment%20Tracker/cumulative.php',
      ),
    );
  }
}