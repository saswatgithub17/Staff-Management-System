import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_task_management/Admin_DashBoard.dart';
import 'package:staff_task_management/Admin_leave_Mgmt.dart';
import 'package:staff_task_management/Staff_List.dart';
import 'package:staff_task_management/main.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _currentIndex = 0;
  List<dynamic> pendingLeaves = [];
  bool _hasShownPopup = false;

  final List<Widget> _pages = [
    StaffList(),
    const Admin_Dashboard(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingLeaves();
    });
  }

  Future<void> _checkPendingLeaves() async {
    try {
      var url = Uri.parse('https://creativecollege.in/Flutter/Leave_Data.php');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> allData = json.decode(response.body);
        List<dynamic> pendingData =
        allData.where((item) => item['Status'] == 'Pending').toList();

        if (mounted) {
          setState(() {
            pendingLeaves = pendingData;
          });
        }

        if (pendingData.isNotEmpty && !_hasShownPopup && mounted) {
          _hasShownPopup = true;
          _showLeaveNotification(context, pendingData);
        }
      }
    } catch (_) {}
  }

  void _showLeaveNotification(BuildContext context, List<dynamic> leaves) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pending Leave Requests',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You have ${leaves.length} pending leave request(s):'),
                const SizedBox(height: 10),
                ...leaves
                    .map((leave) => ListTile(
                  title: Text(leave['Name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Reason: ${leave['Reason']}\nDates: ${leave['Start_Date']} to ${leave['Last_Date']}'),
                ))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('View All',
                  style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Admin_Leave_Page()),
                );
              },
            ),
            TextButton(
              child: const Text('Dismiss', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('isLoggedInAdmin');
    await prefs.remove('userID');
    await prefs.remove('password');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Hi, Admin',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (pendingLeaves.isNotEmpty) {
                      _showLeaveNotification(context, pendingLeaves);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'No pending leave requests',
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                ),
                if (pendingLeaves.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        pendingLeaves.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              size: 24,
              color: Colors.redAccent,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    title: const Text("Confirm Logout",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    content: const Text("Are you sure you want to logout?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          clearSharedPreferences();
                        },
                        child: const Text("Logout",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
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
              color: Colors.black.withOpacity(0.15),
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
                  child: Icon(Icons.people_alt_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.people_alt_rounded,
                      size: 26, color: Color(0xFF6366F1)),
                ),
                label: 'Staff Status',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.grid_view_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.grid_view_rounded,
                      size: 26, color: Color(0xFF6366F1)),
                ),
                label: 'Dashboard',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
