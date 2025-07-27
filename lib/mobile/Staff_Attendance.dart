import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Staff_Attendance extends StatefulWidget {
  @override
  State<Staff_Attendance> createState() => _StaffListState();
}

class _StaffListState extends State<Staff_Attendance> {
  List<dynamic> attendanceItems = [];
  DateTime? selectedDate;
  int totalPresent = 0;
  String name = 'Staff';
  String userID = '';
  bool isLoading = false;
  String errorMessage = '';
  bool hasError = false;

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String selectedMonth = '';

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedMonth = months[selectedDate!.month - 1];
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      userID = prefs.getString('userID') ?? '';

      if (userID.isEmpty) {
        throw Exception('User ID not found in local storage');
      }

      await _fetchProfileData();
      await _fetchAttendanceData();
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProfileData() async {
    final response = await http.get(
      Uri.parse('https://creativecollege.in/Flutter/Profile.php?id=$userID'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        setState(() {
          name = data[0]['name']?.toString()?.trim() ?? 'Staff';
        });
      }
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      hasError = false;
      attendanceItems = [];
      totalPresent = 0;
    });

    try {
      final monthString = selectedDate!.month.toString().padLeft(2, '0');
      final year = selectedDate!.year;

      final url = Uri.parse(
          "https://creativecollege.in/Attendance/att_report_api.php?user=${Uri.encodeComponent(userID)}&selectedMonth=$monthString&selectedYear=$year"
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          attendanceItems = data;
          totalPresent = data.length;
        });
      } else {
        throw Exception("Failed to load attendance: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load attendance data: ${e.toString()}';
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedMonth = months[selectedDate!.month - 1];
      });
      await _fetchAttendanceData();
    }
  }

  Widget _buildAttendanceList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (attendanceItems.isEmpty) {
      return Center(
        child: Text(
          'No attendance records found for $selectedMonth',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return FadeInUp(
      duration: Duration(milliseconds: 1000),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: attendanceItems.length,
        itemBuilder: (context, index) {
          final item = attendanceItems[index];
          final checkOutTime = item['check_out']?.toString() ?? 'Not checked out';
          final isCheckedOut = checkOutTime != '00:00:00' && checkOutTime != 'Not checked out';

          return Column(
            children: [
              ListTile(
                title: Text('Date: ${item['date'] ?? 'N/A'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check In: ${item['check_in'] ?? 'N/A'}'),
                    Text('Check Out: $checkOutTime'),
                  ],
                ),
                trailing: Text(
                  isCheckedOut ? 'Present' : 'Checked In',
                  style: TextStyle(
                    color: isCheckedOut ? Colors.blue : Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: Colors.black, thickness: 1),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            backgroundColor: Colors.black,
            floating: false,
            pinned: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Text(
                      '$totalPresent',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_month, color: Colors.white),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: _buildAttendanceList(),
            ),
          ),
        ],
      ),
      floatingActionButton: hasError
          ? FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: _initializeUserData,
      )
          : null,
    );
  }
}