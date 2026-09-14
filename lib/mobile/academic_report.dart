import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AcademicReportWebView extends StatefulWidget {
  const AcademicReportWebView({Key? key}) : super(key: key);

  @override
  State<AcademicReportWebView> createState() => _AcademicReportWebViewState();
}

class _AcademicReportWebViewState extends State<AcademicReportWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://creativecollege.in/Creative_users/Admin%20Panel%201/Academic%20Report/student_list.php'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
        ],
      ),
    );
  }
}
