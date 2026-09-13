import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:staff_task_management/Dashboard.dart';
import 'package:staff_task_management/mobile/mob_Profile.dart';
import 'package:staff_task_management/mobile/ImageList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _currentIndex = 0;
  late String pickedImagePath;
  final List<Widget> _pages = [
    Dashboard(),
    ImageList(),
    const Profile(),
  ];

  String name = '';

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.get(Uri.parse('https://creativecollege.in/Flutter/Profile.php?id=$userID'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData is List && jsonData.isNotEmpty) {
        final firstElement = jsonData[0];
        setState(() {
          name = firstElement['name'];
        });
      } else {
        setState(() {
          name = 'Data not found';
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
    fetchData();
  }

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          color: Colors.white, // Set background to white
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedLabelStyle: const TextStyle(color: Colors.black), // Selected label style
            unselectedLabelStyle: const TextStyle(color: Colors.grey), // Unselected label style
            items: [
              BottomNavigationBarItem(
                icon: _currentIndex == 0
                    ? const Icon(Icons.dashboard, color: Colors.black)
                    : const Icon(Icons.dashboard, color: Colors.grey),
                label: 'DashBoard',
                backgroundColor: Colors.white,
                activeIcon: const Icon(Icons.dashboard, color: Colors.black),
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 1
                    ? const Icon(Icons.note_sharp, color: Colors.black)
                    : const Icon(Icons.note_sharp, color: Colors.grey),
                label: 'Notice',
                backgroundColor: Colors.white,
                activeIcon: const Icon(Icons.note_sharp, color: Colors.black),
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 2
                    ? const Icon(Icons.person_outline, color: Colors.black)
                    : const Icon(Icons.person_outline, color: Colors.grey),
                label: 'Profile',
                backgroundColor: Colors.white,
                activeIcon: const Icon(Icons.person_outline, color: Colors.black),
              ),
            ],
            type: BottomNavigationBarType.fixed, // Important to set the type to fixed
          ),
        ),
      ),
    );
  }
}