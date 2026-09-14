import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_task_management/Dashboard.dart';
import 'package:staff_task_management/mobile/ImageList.dart';
import 'package:staff_task_management/mobile/mob_Profile.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const Dashboard(),
    ImageList(),
    const Profile(),
  ];

  String name = '';

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    if (userID.isEmpty) return;

    try {
      final response = await http.get(Uri.parse(
          'https://creativecollege.in/Flutter/Profile.php?id=$userID'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is List && jsonData.isNotEmpty) {
          final firstElement = jsonData[0];
          if (mounted) {
            setState(() {
              name = firstElement['name'] ?? '';
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            elevation: 0,
            backgroundColor: const Color(0xFF0F172A),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.shade500,
            selectedFontSize: 13,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.grid_view_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.grid_view_rounded, size: 26, color: Color(0xFF6366F1)),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.campaign_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.campaign_rounded, size: 26, color: Color(0xFF6366F1)),
                ),
                label: 'Notice',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline_rounded, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_rounded, size: 26, color: Color(0xFF6366F1)),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
