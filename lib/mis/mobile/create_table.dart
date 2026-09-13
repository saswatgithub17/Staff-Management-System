import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

late WebViewWrapper webViewWrapper;

void setupWebView() {
  if (kIsWeb) {
    webViewWrapper = WebWebView();
  } else {
    webViewWrapper = MobileWebView();
  }
}

abstract class WebViewWrapper {
  Widget buildWebView(String url);
}

class MobileWebView implements WebViewWrapper {
  @override
  Widget buildWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
    return WebViewWidget(controller: controller);
  }
}

class WebWebView implements WebViewWrapper {
  @override
  Widget buildWebView(String url) {
    try {
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      );
    } catch (e) {
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

class CreateTable extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CreateTable({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<CreateTable> createState() => _CreateTableState();
}

class _CreateTableState extends State<CreateTable> {
  @override
  void initState() {
    super.initState();
    setupWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: webViewWrapper.buildWebView(
        'https://creativecollege.in/Creative_users/Admin%20Panel%201/Notes%20And%20Assignment%20Tracker/create_table.php',
      ),
    );
  }
}
