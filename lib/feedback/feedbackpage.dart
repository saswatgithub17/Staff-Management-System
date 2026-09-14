import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Feedbackpage extends StatefulWidget {
  const Feedbackpage({Key? key}) : super(key: key);

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedbackpage> {
  late Future<Map<String, List<Map<String, dynamic>>>> futureData;
  String selectedCourse = 'All';

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchData() async {
    final response = await http.get(Uri.parse('https://creativecollege.in/Flutter/Feedback/fetbackfetch.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      Map<String, List<Map<String, dynamic>>> groupedData = {};

      for (var item in data) {
        String week = (item['weak'] ?? '1').toString();
        if (!groupedData.containsKey(week)) {
          groupedData[week] = [];
        }
        groupedData[week]!.add(item as Map<String, dynamic>);
      }

      return groupedData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Map<String, List<Map<String, dynamic>>> filterData(
      Map<String, List<Map<String, dynamic>>> data, String course) {
    if (course == 'All') {
      return data;
    }

    final filteredData = <String, List<Map<String, dynamic>>>{};
    data.forEach((week, items) {
      final filteredItems = items.where((item) => item['cource'] == course).toList();
      if (filteredItems.isNotEmpty) {
        filteredData[week] = filteredItems;
      }
    });
    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Feedback Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('All', selectedCourse == 'All'),
                _buildFilterButton('BBA', selectedCourse == 'BBA'),
                _buildFilterButton('BCA', selectedCourse == 'BCA'),
                _buildFilterButton('BSC', selectedCourse == 'BSC'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No feedback available at this time', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                final groupedData = filterData(snapshot.data!, selectedCourse);

                if (groupedData.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No data available for selected course', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: groupedData.keys.map((week) {
                    final items = groupedData[week]!;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
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
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        title: Text(
                          'Week $week',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        tilePadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFEEF2FF),
                                child: const Icon(Icons.person_rounded, color: Color(0xFF4F46E5)),
                              ),
                              title: Text(
                                item['teacher_name'] ?? 'Teacher',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                              ),
                              subtitle: Text(
                                'Subject: ${item['subject'] ?? '-'}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Score: ${item['average_score'] ?? '-'}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['cource'] ?? ''}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(text),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCourse = text;
          });
        },
        selectedColor: const Color(0xFF4F46E5),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1E293B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
