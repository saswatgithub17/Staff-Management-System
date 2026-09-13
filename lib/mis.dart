import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatelessWidget {
  final String url = "https://creativecollege.in/Creative_users/Admin%20Panel%201/Notes%20And%20Assignment%20Tracker/index.php";

  void _launchURL() async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Open in Browser")),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchURL,
          child: Text("Open in Chrome"),
        ),
      ),
    );
  }
}
