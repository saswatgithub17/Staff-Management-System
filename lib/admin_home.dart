import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
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
    Admin_Dashboard(),
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
        List<dynamic> pendingData = allData.where((item) => item['Status'] == 'Pending').toList();

        setState(() {
          pendingLeaves = pendingData;
        });

        if (pendingData.isNotEmpty && !_hasShownPopup) {
          _hasShownPopup = true;
          _showLeaveNotification(context, pendingData);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error checking leave requests',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showLeaveNotification(BuildContext context, List<dynamic> leaves) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pending Leave Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You have ${leaves.length} pending leave request(s):'),
                SizedBox(height: 10),
                ...leaves.map((leave) => ListTile(
                  title: Text(leave['Name'] ?? 'Unknown'),
                  subtitle: Text('Reason: ${leave['Reason']}\nDates: ${leave['Start_Date']} to ${leave['Last_Date']}'),
                )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('View All', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Admin_Leave_Page()),
                );
              },
            ),
            TextButton(
              child: Text('Dismiss', style: TextStyle(color: Colors.grey)),
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    size: 30,
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
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pendingLeaves.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              size: 30,
              color: Colors.white,
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
                    title: Text("Confirm Logout"),
                    content: Text("Are you sure you want to logout"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          clearSharedPreferences();
                          Navigator.of(context).pop();
                        },
                        child: Text("Logout", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        title: Text(
          'Hi.. ,  Admin',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: Container(
          color: Colors.black,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.work, color: Colors.white),
                label: 'Staff Status',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_customize, color: Colors.white),
                label: 'Dashboard',
              ),
            ],
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
