import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Attendance extends StatefulWidget {
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  String selectedCourse = 'BBA';
  String selectedSemester = '1st';
  Map<String, dynamic>? allData;
  Map<String, dynamic>? filteredData;
  DateTime currentDate = DateTime.now();
  Map<String, Map<String, dynamic>> attendanceStatus = {};
  bool isLoading = false;

  // Semester groups mapping
  final Map<String, List<String>> semesterGroups = {
    '1st': ['1st'],
    '2nd': ['2nd'],
    '3rd': ['3rd'],
    '4th': ['4th'],
    '5th': ['5th'],
    '6th': ['6th'],
    '7th': ['7th'],
    '8th': ['8th'],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await fetchData();
      setState(() {
        allData = data;
        filteredData = _filterData(data, selectedCourse, selectedSemester);
        _initializeAttendanceStatus(filteredData);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/New_attendance/Fetch_student_data.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _filterData(
      Map<String, dynamic> data, String course, String semester) {
    final filtered = <String, dynamic>{};
    final semesterList = semesterGroups[semester] ?? [];

    data.forEach((key, records) {
      final sortedRecords = (records as List<dynamic>)
          .where((record) => semesterList.contains(record['SEMESTER']) &&
          record['COURSE'] == course)
          .toList()
        ..sort((a, b) => a['NAME'].compareTo(b['NAME']));

      if (sortedRecords.isNotEmpty) {
        filtered[key] = sortedRecords;
      }
    });
    return filtered;
  }

  void _initializeAttendanceStatus(Map<String, dynamic>? data) {
    final status = <String, Map<String, dynamic>>{};
    if (data != null) {
      data.values.expand((records) => records).forEach((record) {
        status[record['ID']] = {
          'name': record['NAME'],
          'id': record['ID'],
          'present': false,
        };
      });
    }
    setState(() {
      attendanceStatus = status;
    });
  }

  void _toggleAttendance(String id) {
    setState(() {
      final student = attendanceStatus[id];
      if (student != null) {
        student['present'] = !student['present'];
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != currentDate) {
      setState(() {
        currentDate = picked;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No students to submit attendance for')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://creativecollege.in/Flutter/New_attendance/attendance.php');

      final List<Map<String, dynamic>> attendanceList =
      attendanceStatus.values.map((student) {
        return {
          'id': student['id'],
          'present': student['present'] ? 1 : 0,
          'date': DateFormat('yyyy-MM-dd').format(currentDate),
          'semester_group': selectedSemester,  // Changed from 'semester' to 'semester_group'
          'course': selectedCourse,
        };
      }).toList();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(attendanceList),
      ).timeout(Duration(seconds: 15));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Error submitting')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Please check your internet connection')),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request timeout: Please try again')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Date Picker
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    DateFormat('dd-MMM-yyyy').format(currentDate),
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              // Course Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['BBA', 'BSC-C', 'BCA'].map((course) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(course),
                          selected: selectedCourse == course,
                          onSelected: (selected) {
                            setState(() {
                              selectedCourse = course;
                              filteredData = _filterData(
                                  allData ?? {}, selectedCourse, selectedSemester);
                              _initializeAttendanceStatus(filteredData);
                            });
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: selectedCourse == course
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Semester Selection
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: semesterGroups.keys.map((semester) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(semester),
                          selected: selectedSemester == semester,
                          onSelected: (selected) {
                            setState(() {
                              selectedSemester = semester;
                              filteredData = _filterData(
                                  allData ?? {}, selectedCourse, selectedSemester);
                              _initializeAttendanceStatus(filteredData);
                            });
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: selectedSemester == semester
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Student List
              Expanded(
                child: isLoading && filteredData == null
                    ? Center(child: CircularProgressIndicator(color: Colors.black))
                    : filteredData == null
                    ? Center(child: Text('Data not loaded'))
                    : filteredData!.isEmpty
                    ? Center(child: Text('No students found for selected criteria'))
                    : ListView.builder(
                  itemCount: filteredData!.values
                      .expand((e) => e)
                      .length,
                  itemBuilder: (context, index) {
                    final record = filteredData!.values
                        .expand((e) => e)
                        .elementAt(index);
                    final id = record['ID'];
                    final name = record['NAME'];
                    final isPresent =
                        attendanceStatus[id]?['present'] ?? false;

                    return Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: CheckboxListTile(
                        title: Text(
                          name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('ID: $id'),
                        value: isPresent,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _toggleAttendance(id);
                          }
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(
                            name[0],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        activeColor: Colors.black,
                      ),
                    );
                  },
                ),
              ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'SUBMIT ATTENDANCE',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
        ],
      ),
    );
  }
}