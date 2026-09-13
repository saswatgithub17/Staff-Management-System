// lib/mis/mis.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mobile/mis_home.dart';

class MIS extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MIS({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://creativecollege.in/Creative_users/Admin%20Panel%201/Notes%20And%20Assignment%20Tracker/index.php');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 600px as the breakpoint between mobile and desktop
        final isMobile = constraints.maxWidth < 600;

        return isMobile
            ? MISHome(
          isDarkMode: isDarkMode,
          onToggleTheme: onToggleTheme,
        )
            : FutureBuilder(
          future: _launchUrl(),
          builder: (context, snapshot) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
}