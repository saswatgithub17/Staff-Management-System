import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_task_management/Report_upload.dart';
import 'package:staff_task_management/attendance/attendance.dart';
import 'package:staff_task_management/feedback/stafffeedback.dart';
import 'package:staff_task_management/mobile/Staff_Attendance.dart';
import 'package:staff_task_management/mobile/academic_report.dart';
import 'package:staff_task_management/mobile/detailsMobile.dart';
import 'package:staff_task_management/mobile/mob_add_task.dart';
import 'package:staff_task_management/mobile/mob_contact_prev.dart';
import 'package:staff_task_management/mobile/mob_task_mgmt.dart';
import 'package:staff_task_management/staff_leave.dart';
import 'package:staff_task_management/student_attendance.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mis/mis.dart';
import 'mobile/mob_Profile.dart';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:staff_task_management/admin_leave_mgmt.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
  static const _lastSeenLeaveKey = 'lastSeenLeaveStatus';
  static const _hasSeenLeavePopupKey = 'hasSeenLeavePopup';
  final _color1 = const Color(0xFFC21E56);
  XFile? _pickedImage;
  Map<String, dynamic>? data;
  bool isLoading = true;
  String error = '';
  bool _showDesignerCredit = true;
  List<dynamic> myLeaveRequests = [];
  bool _showLeaveStatusPopup = false;
  Map<String, dynamic>? _latestLeaveStatus;
  String? _latestStatusKey;

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');
    if (savedImagePath != null) {
      setState(() => _pickedImage = XFile(savedImagePath));
    }
  }

  Future<void> fetchMyLeaveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID') ?? '';

    final url = Uri.parse('https://creativecollege.in/Flutter/Leave_Data.php');
    final response = await http.get(url);
    if (response.statusCode != 200) return;

    final allData = json.decode(response.body) as List<dynamic>;
    final myData = allData.where((item) => item['ID'] == userID).toList();
    if (myData.isEmpty) return;

    final latest = myData.last as Map<String, dynamic>;
    final status = latest['Status'] as String;
    final statusKey = '${latest['Start_Date']}_${latest['Last_Date']}_$status';

    final hasSeenPopup = prefs.getBool(_hasSeenLeavePopupKey) ?? false;
    final seenKey = prefs.getString(_lastSeenLeaveKey);

    // Only show if:
    // 1. Status is not pending
    // 2. It's a new status we haven't seen before
    // 3. User hasn't seen any popup yet for this status
    if (status != 'Pending' &&
        statusKey != seenKey &&
        !hasSeenPopup) {
      setState(() {
        _latestLeaveStatus = latest;
        _latestStatusKey = statusKey;
        _showLeaveStatusPopup = true;
      });
    }
  }

  Future<void> fetchData(String id) async {
    final url =
        'https://creativecollege.in/Flutter/Work/singledata_redflag.php?id=$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagePath();
    fetchData("Bhabani@CTC");
    fetchMyLeaveRequests();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _showDesignerCredit = false);
    });
  }

  Widget _buildCard(
      String imagePath, String title, Color accentColor, VoidCallback onTap, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = constraints.maxWidth;
        return FadeInUp(
          duration: Duration(milliseconds: 250 + (index * 50)),
          child: Container(
            margin: EdgeInsets.all(cardSize * 0.015),
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
                  padding: EdgeInsets.all(cardSize * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: cardSize * 0.42,
                        height: cardSize * 0.42,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            imagePath,
                            width: cardSize * 0.28,
                            height: cardSize * 0.28,
                          ),
                        ),
                      ),
                      SizedBox(height: cardSize * 0.06),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: cardSize * 0.065,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  final String url =
      "https://creativecollege.in/Creative_users/Admin%20Panel%201/Notes%20And%20Assignment%20Tracker/index.php";

  void _launchURL() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.2, // Responsive height
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: BannerDisplay(),
            ),
          ),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth < 600 ? 2 : 4,
                    mainAxisSpacing: constraints.maxWidth * 0.03,
                    crossAxisSpacing: constraints.maxWidth * 0.03,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildCard(
                          'assets/icons/contact.png',
                          'Student Contact Record',
                          const Color(0xFF0D9488), // Teal
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ContactPrev()),
                          ),
                          index,
                        );
                      case 1:
                        return _buildCard(
                          'assets/icons/student attendance.png',
                          'Student Attendance',
                          const Color(0xFF8B5CF6), // Purple
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Attendance()),
                          ),
                          index,
                        );
                      case 2:
                        return _buildCard(
                          'assets/icons/work.png',
                          'Work Details',
                          const Color(0xFF4F46E5), // Indigo
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsMobile()),
                          ),
                          index,
                        );
                      case 3:
                        return _buildCard(
                          'assets/icons/task.png',
                          'Task Management',
                          const Color(0xFF0284C7), // Blue
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Task_mgmt()),
                          ),
                          index,
                        );
                      case 4:
                        return _buildCard(
                          'assets/icons/report.png',
                          'Academic Report',
                          const Color(0xFF059669), // Emerald Green
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AcademicReportWebView()),
                          ),
                          index,
                        );
                      case 5:
                        return _buildCard(
                          'assets/icons/report.png',
                          'Report',
                          const Color(0xFF0891B2), // Cyan
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Report_upload()),
                          ),
                          index,
                        );
                      case 6:
                        return _buildCard(
                          'assets/icons/add task.png',
                          'Add Task',
                          const Color(0xFFD97706), // Amber
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Mob_Add_Task()),
                          ),
                          index,
                        );
                      case 7:
                        return _buildCard(
                          'assets/icons/apply for leave.png',
                          'Apply Leave',
                          const Color(0xFF38BDF8), // Sky Blue
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Leave_Page()),
                          ),
                          index,
                        );
                      case 8:
                        return _buildCard(
                          'assets/icons/feedback.png',
                          'Feedback',
                          const Color(0xFFE11D48), // Rose
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeacherFeedbackpage()),
                          ),
                          index,
                        );
                      case 9:
                        return _buildCard(
                          'assets/icons/mis.png',
                          'Notes & Assignment',
                          const Color(0xFF7C3AED), // Deep Violet
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MIS(
                                isDarkMode: _isDarkMode,
                                onToggleTheme: _toggleTheme,
                              ),
                            ),
                          ),
                          index,
                        );
                      default:
                        return Container();
                    }
                  },
                ),
              ),

              if (_showDesignerCredit)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: 1.0,
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Designed by Ananta k.swain',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_showLeaveStatusPopup && _latestLeaveStatus != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: FadeInUp(
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            'Leave Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Your leave request has been ${_latestLeaveStatus!['Status']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Reason: ${_latestLeaveStatus!['Reason']}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Dates: ${_latestLeaveStatus!['Start_Date']} to ${_latestLeaveStatus!['Last_Date']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                // Mark this popup as seen
                                await prefs.setBool(_hasSeenLeavePopupKey, true);
                                if (_latestStatusKey != null) {
                                  await prefs.setString(
                                      _lastSeenLeaveKey, _latestStatusKey!);
                                }
                                setState(() {
                                  _showLeaveStatusPopup = false;
                                });
                              },
                              child: Text('OK'),
                            ),
                            if (_latestLeaveStatus!['Status'] == 'Rejected')
                              TextButton(
                                onPressed: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  // Mark this popup as seen
                                  await prefs.setBool(_hasSeenLeavePopupKey, true);
                                  if (_latestStatusKey != null) {
                                    await prefs.setString(
                                        _lastSeenLeaveKey, _latestStatusKey!);
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Leave_Page()),
                                  ).then((_) {
                                    setState(() {
                                      _showLeaveStatusPopup = false;
                                    });
                                  });
                                },
                                child: Text(
                                  'REAPPLY',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BannerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateTime.now().weekday;
    final bannerImages = [
      'assets/images/banner1.png',
      'assets/images/banner2.jpg',
      'assets/images/banner3.jpg',
      'assets/images/banner4.png',
      'assets/images/banner5.png',
      'assets/images/banner6.png',
      'assets/images/banner7.jpg',
    ];
    final bannerIndex = dayOfWeek % bannerImages.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust banner height based on screen size
        final bannerHeight = constraints.maxHeight;
        final bannerWidth = constraints.maxWidth;

        return Container(
          height: bannerHeight,
          width: bannerWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bannerImages[bannerIndex]),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}