import 'package:flutter/material.dart';
import 'package:staff_task_management/Add_staff.dart';
import 'package:staff_task_management/Admin_Contact.dart';
import 'package:staff_task_management/Admin_DateWise_Work_View.dart';
import 'package:staff_task_management/Admin_leave_Mgmt.dart';
import 'package:staff_task_management/admin_add_work.dart';
import 'package:staff_task_management/attendance/attendance.dart';
import 'package:staff_task_management/del_staff.dart';
import 'package:staff_task_management/feedback/feedbackpage.dart';

class Admin_Dashboard extends StatefulWidget {
  const Admin_Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Admin_Dashboard> {
  // Black and white color scheme
  final Color primaryColor = Colors.black;
  final Color backgroundColor = Colors.white;
  final Color cardColor = Colors.white;
  final Color textColor = Colors.black;
  final Color iconColor = Colors.black87;
  final Color borderColor = Colors.grey.shade300;

  Widget _buildDashboardCard(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
          final childAspectRatio = constraints.maxWidth < 600 ? 1.0 : 1.1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _buildDashboardItems(context),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDashboardItems(BuildContext context) {
    return [
      _buildDashboardCard(Icons.calendar_today, 'Date Wise Work', () {
        _navigateTo(context, AdminDateWiseWork());
      }),
      _buildDashboardCard(Icons.beach_access, 'Staff Leave', () {
        _navigateTo(context, Admin_Leave_Page());
      }),
      _buildDashboardCard(Icons.person_add, 'Add Staff', () {
        _navigateTo(context, StaffAdd());
      }),
      _buildDashboardCard(Icons.person_remove, 'Delete Staff', () {
        _navigateTo(context, StaffDelete());
      }),
      _buildDashboardCard(Icons.contacts, 'Student Contact', () {
        _navigateTo(context, Admin_ContactPrev());
      }),
      _buildDashboardCard(Icons.people, 'Student Attendance', () {
        _navigateTo(context, Attendance());
      }),
      _buildDashboardCard(Icons.assignment, 'Assign Work', () {
        _navigateTo(context, Admin_ADD_WORK());
      }),
      _buildDashboardCard(Icons.comment, 'Feedback', () {
        _navigateTo(context, Feedbackpage());
      }),
    ];
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }
}