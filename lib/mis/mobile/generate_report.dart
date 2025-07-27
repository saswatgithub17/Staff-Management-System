import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Conditional imports
late WebViewWrapper webViewWrapper;

void setupWebView() {
  if (kIsWeb) {
    // Web implementation (browser)

    webViewWrapper = WebWebView();
  } else {
    // Mobile implementation (APK)

    webViewWrapper = MobileWebView();
  }
}

abstract class WebViewWrapper {
  Widget buildWebView(String url);
}

// Mobile (APK) implementation
class MobileWebView implements WebViewWrapper {
  @override
  Widget buildWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
    return WebViewWidget(controller: controller);
  }
}

// Web (browser) implementation
class WebWebView implements WebViewWrapper {
  @override
  Widget buildWebView(String url) {
    try {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      );
    } catch (e) {
      // Fallback: If iframe fails, show a button to open in a new tab
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Could not load content directly"),
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

class GenerateReport extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const GenerateReport({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<GenerateReport> createState() => _GenerateReportState();
}

class _GenerateReportState extends State<GenerateReport> {
  @override
  void initState() {
    super.initState();
    setupWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: webViewWrapper.buildWebView(
        'https://creativecollege.in/MIS/MIS/Notes%20And%20Assignment%20Tracker/report.php',
      ),
    );
  }}
