import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Total_Attendance extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<Total_Attendance> {
  List<dynamic> staffList = [];
  Map<String, dynamic>? selectedStaff;
  List<dynamic> attendanceData = [];
  bool isLoading = false;
  String errorMessage = '';
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String selectedYear = DateTime.now().year.toString();

  Future<void> fetchStaffList() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://creativecollege.in/Flutter/staff_list.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          staffList = data;
          staffList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        throw Exception('Failed to load staff list');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStaffAttendance(String staffId) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      attendanceData = [];
    });

    try {
      final monthNumber =
      DateFormat('MM').format(DateFormat('MMMM').parse(selectedMonth));

      final response = await http.get(
        Uri.parse(
          'https://creativecollege.in/Attendance/att_report_api.php?user=$staffId&selectedMonth=$monthNumber&selectedYear=$selectedYear',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          attendanceData = data;
        });
      } else {
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading attendance: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStaffList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Attendance'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month and Year Selector
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildMonthDropdown()),
                SizedBox(width: 10),
                Expanded(child: _buildYearDropdown()),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Row(
              children: [
                // Staff List
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: _buildStaffList(),
                ),

                // Attendance Details
                Expanded(
                  child: Column(
                    children: [
                      if (selectedStaff != null) _buildStaffInfo(),
                      Divider(height: 1),
                      Expanded(child: _buildAttendanceList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      child: DropdownButton<String>(
        value: selectedMonth,
        onChanged: (String? newValue) {
          setState(() {
            selectedMonth = newValue!;
            if (selectedStaff != null) {
              fetchStaffAttendance(selectedStaff!['user_name']);
            }
          });
        },
        items: [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(fontSize: 14)),
          );
        }).toList(),
        underline: SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, size: 20),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      child: DropdownButton<String>(
        value: selectedYear,
        onChanged: (String? newValue) {
          setState(() {
            selectedYear = newValue!;
            if (selectedStaff != null) {
              fetchStaffAttendance(selectedStaff!['user_name']);
            }
          });
        },
        items: <String>['2023', '2024', '2025', '2026', '2027']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(fontSize: 14)),
          );
        }).toList(),
        underline: SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, size: 20),
      ),
    );
  }

  Widget _buildStaffList() {
    if (isLoading && staffList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return ListView.builder(
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final staff = staffList[index];
        final isSelected = selectedStaff?['user_name'] == staff['user_name'];

        return Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border:
            isSelected ? Border.all(color: Colors.blue, width: 1) : null,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
              isSelected ? Colors.blue[100] : Colors.grey[200],
              child: Text(
                staff['name'][0],
                style: TextStyle(
                  color: isSelected ? Colors.blue[800] : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              staff['name'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue[800] : Colors.black,
              ),
            ),
            subtitle: Text(
              staff['user_name'],
              style: TextStyle(
                color: isSelected ? Colors.blue[600] : Colors.grey[600],
              ),
            ),
            onTap: () {
              setState(() {
                selectedStaff = staff;
              });
              fetchStaffAttendance(staff['user_name']);
            },
          ),
        );
      },
    );
  }

  Widget _buildStaffInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(
              selectedStaff!['name'][0],
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedStaff!['name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('ID: ${selectedStaff!['user_name']}',
                    style: TextStyle(fontSize: 13)),
                if (selectedStaff!['email'] != null) ...[
                  SizedBox(height: 2),
                  Text('Email: ${selectedStaff!['email']}',
                      style: TextStyle(fontSize: 13)),
                ],
                if (selectedStaff!['phone'] != null) ...[
                  SizedBox(height: 2),
                  Text('Phone: ${selectedStaff!['phone']}',
                      style: TextStyle(fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (selectedStaff == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 50, color: Colors.grey[400]),
            SizedBox(height: 10),
            Text(
              'Select a staff member to view attendance',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(errorMessage, style: TextStyle(color: Colors.red)),
      );
    }

    if (attendanceData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 50, color: Colors.grey[400]),
            SizedBox(height: 10),
            Text(
              'No attendance records for $selectedMonth $selectedYear',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: attendanceData.length,
      itemBuilder: (context, index) {
        final record = attendanceData[index];
        final isPresent = record['check_out'] != null &&
            record['check_out'] != '00:00:00';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPresent ? Colors.green[50] : Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPresent ? Icons.check : Icons.schedule,
                    color: isPresent ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['date'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'In: ${record['check_in']}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Out: ${isPresent ? record['check_out'] : '--:--:--'}',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              isPresent ? Colors.grey[700] : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
