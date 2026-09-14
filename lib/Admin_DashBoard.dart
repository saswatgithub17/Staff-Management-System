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
  Widget _buildDashboardCard(IconData icon, String title, Color accentColor, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: accentColor.withOpacity(0.12),
          highlightColor: accentColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: accentColor),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
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
      _buildDashboardCard(Icons.calendar_today_rounded, 'Date Wise Work', const Color(0xFF4F46E5), () {
        _navigateTo(context, const AdminDateWiseWork());
      }),
      _buildDashboardCard(Icons.beach_access_rounded, 'Staff Leave', const Color(0xFF0284C7), () {
        _navigateTo(context, const Admin_Leave_Page());
      }),
      _buildDashboardCard(Icons.person_add_alt_1_rounded, 'Add Staff', const Color(0xFF16A34A), () {
        _navigateTo(context, const StaffAdd());
      }),
      _buildDashboardCard(Icons.person_remove_rounded, 'Delete Staff', const Color(0xFFDC2626), () {
        _navigateTo(context, const StaffDelete());
      }),
      _buildDashboardCard(Icons.contacts_rounded, 'Student Contact', const Color(0xFF0D9488), () {
        _navigateTo(context, const Admin_ContactPrev());
      }),
      _buildDashboardCard(Icons.people_alt_rounded, 'Student Attendance', const Color(0xFF8B5CF6), () {
        _navigateTo(context, Attendance());
      }),
      _buildDashboardCard(Icons.assignment_rounded, 'Assign Work', const Color(0xFFD97706), () {
        _navigateTo(context, const Admin_ADD_WORK());
      }),
      _buildDashboardCard(Icons.comment_rounded, 'Feedback', const Color(0xFFE11D48), () {
        _navigateTo(context, const Feedbackpage());
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
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
