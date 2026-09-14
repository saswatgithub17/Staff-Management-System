import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminDateWiseWork extends StatefulWidget {
  const AdminDateWiseWork({Key? key}) : super(key: key);

  @override
  _AdminDateWiseWorkState createState() => _AdminDateWiseWorkState();
}

class _AdminDateWiseWorkState extends State<AdminDateWiseWork> {
  late DateTime _selectedDate;
  String _filterValue = 'All';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<List<Map<String, dynamic>>> fetchData(DateTime selectedDate) async {
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/Track_Work.php?date=${selectedDate.toString()}'));

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(jsonData);

        data = data.where((item) {
          try {
            DateTime itemDate = DateTime.parse(item['ADDDATE'] ?? '');
            return itemDate.year == selectedDate.year &&
                itemDate.month == selectedDate.month &&
                itemDate.day == selectedDate.day;
          } catch (_) {
            return false;
          }
        }).toList();

        data.sort((a, b) => (a['ID'] ?? '').compareTo(b['ID'] ?? ''));

        return data;
      } catch (_) {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _setFilter(String value) {
    setState(() {
      _filterValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: Text(
              'Date: ${DateFormat('dd-MMM-yyyy').format(_selectedDate)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
                onPressed: () => _selectDate(context),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: _setFilter,
                itemBuilder: (BuildContext context) {
                  return ['All', 'Started', 'Not Started'].map((String choice) {
                    String displayChoice = choice;
                    if (choice == 'Started') {
                      displayChoice = 'Active';
                    } else if (choice == 'Not Started') {
                      displayChoice = 'Pending';
                    }
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(displayChoice,
                          style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500)),
                    );
                  }).toList();
                },
                icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
              ),
            ],
            floating: false,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchData(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  List<Map<String, dynamic>> filteredData = snapshot.data!;
                  if (_filterValue != 'All') {
                    filteredData = filteredData
                        .where((work) => work['STATUS'] == _filterValue)
                        .toList();
                  }

                  if (filteredData.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: Text(
                          'No work tracked on this date',
                          style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final work = filteredData[index];
                        String status = work['STATUS'] ?? '';
                        String dateToShow = status == 'Started'
                            ? work['STARTDATE'] ?? ''
                            : work['ADDDATE'] ?? '';
                        String statusToShow =
                        status == 'Started' ? 'Active' : 'Pending';

                        final isActive = statusToShow == 'Active';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF64748B).withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isActive
                                        ? Icons.play_circle_fill_rounded
                                        : Icons.pending_actions_rounded,
                                    color: isActive ? Colors.green : Colors.red,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        work['name'] ?? 'Staff Member',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        work['TITLE'] ?? 'Task Title',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Date: $dateToShow',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  child: Text(
                                    statusToShow,
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text('No work tracked on this date', style: TextStyle(color: Colors.grey)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
