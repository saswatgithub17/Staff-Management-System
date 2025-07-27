import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class InsertData extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  const InsertData({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<InsertData> createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  String? selectedBatch;
  String? selectedYear;
  String? selectedSemester;
  String? selectedType;

  bool isLoading = false;
  List<Map<String, dynamic>> studentList = [];
  Map<String, Map<String, dynamic>> modifiedData = {};
  String csrfToken = "";
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final http.Client client = http.Client();
  String sessionCookie = "";
  final Connectivity _connectivity = Connectivity();

  final List<String> batches = ['Batch', 'BCA', 'BSC', 'BBA'];
  final List<String> years = ['Year', '2022-25', '2023-26', '2024-28'];
  final List<String> semesters = [
    'Semester',
    '1st Sem',
    '2nd Sem',
    '3rd Sem',
    '4th Sem',
    '5th Sem',
    '6th Sem',
    '7th Sem',
    '8th Sem',
  ];
  final List<String> types = ['Select Type', 'Notes', 'Assignment', 'Project'];

  String _getApiBatchFormat(String? batch) {
    switch (batch) {
      case 'BCA': return 'bca';
      case 'BSC': return 'bsc-c';
      case 'BBA': return 'bba';
      default: return batch?.toLowerCase() ?? '';
    }
  }

  String _getTableBatchFormat(String? batch) {
    return _getApiBatchFormat(batch);
  }

  String _formatSemesterForTable(String? semester) {
    if (semester == null) return '';
    return semester.toLowerCase().replaceAll(' ', '_');
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return false;
    }
    return true;
  }

  Future<void> _fetchData() async {
    if (!await _checkInternetConnection()) return;

    if (selectedBatch == null || selectedYear == null || selectedSemester == null || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all dropdowns')),
      );
      return;
    }

    setState(() => isLoading = true);
    final apiBatch = _getApiBatchFormat(selectedBatch);
    final tableBatch = _getTableBatchFormat(selectedBatch);
    final formattedYear = selectedYear!.substring(0, 4);
    final formattedSemester = _formatSemesterForTable(selectedSemester);

    try {
      final url = Uri.https(
        'creativecollege.in',
        '/MIS/MIS/api/insert.php',
        {
          'batch': apiBatch,
          'year': formattedYear,
          'semester': formattedSemester,
          'data_type': selectedType!.toLowerCase(),
        },
      );

      debugPrint('Fetch URL: $url');

      final response = await client.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 1) {
          List<dynamic> rawData = body['data'];
          List<Map<String, dynamic>> processedData = [];

          for (var item in rawData) {
            Map<String, dynamic> studentData = {
              'id': item['student_id']?.toString() ?? item['id']?.toString() ?? '',
              'name': item['name']?.toString() ?? '',
              'batch': apiBatch,
              'year': selectedYear,
              'semester': selectedSemester,
            };
            item.forEach((key, value) {
              if (!['student_id', 'name', 'batch', 'year', 'semester', 'id'].contains(key)) {
                studentData[key] = value?.toString() ?? '';
              }
            });
            processedData.add(studentData);
          }

          setState(() {
            studentList = processedData;
            csrfToken = body['csrf_token'] ?? '';
            headers['X-CSRF-TOKEN'] = csrfToken;
          });
        } else {
          setState(() => studentList = []);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'No data found')),
          );
        }
      } else {
        setState(() => studentList = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } on http.ClientException catch (e) {
      setState(() => studentList = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${e.message}')),
      );
    } on TimeoutException {
      setState(() => studentList = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out')),
      );
    } catch (e) {
      setState(() => studentList = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _updateCheckbox(String id, String field, bool checked) {
    modifiedData.putIfAbsent(id, () => {});
    modifiedData[id]![field] = checked ? "YES" : "NO";
  }

  void _updateDate(String id, String field, String date) {
    modifiedData.putIfAbsent(id, () => {});
    modifiedData[id]![field] = date;
  }

  Future<void> _submitData() async {
    if (modifiedData.isEmpty && selectedType != "Project") return;

    final isProject = selectedType?.toLowerCase() == "project";
    if (!isProject) {
      for (var student in studentList) {
        final id = student['id'].toString();
        final fields = student.keys.where((k) =>
        (k.endsWith("_note") || k.endsWith("_assignment") || k.contains("_unit")) &&
            !k.contains("_date"));
        for (var field in fields) {
          final dateField = "${field}_date";
          if (modifiedData.containsKey(id)) {
            if (modifiedData[id]![field] != null && modifiedData[id]![dateField] == null) {
              modifiedData[id]![dateField] = student[dateField]?.toString() ?? '';
            }
          }
        }
      }
    }

    final payload = {
      "csrf_token": csrfToken,
      "batch": _getApiBatchFormat(selectedBatch),
      "year": selectedYear,
      "semester": selectedSemester,
      "data_type": selectedType!.toLowerCase(),
      "data": modifiedData,
    };

    try {
      final response = await client.post(
        Uri.parse('https://creativecollege.in/MIS/MIS/api/insert.php'),
        headers: {
          ...headers, // ✅ includes X-CSRF-TOKEN and Content-Type
          if (sessionCookie.isNotEmpty) "cookie": sessionCookie,
        },
        body: json.encode(payload),
      );

      final res = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Unknown response')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission Error: $e')),
      );
    }
  }

  Widget _buildDataTable() {
    if (studentList.isEmpty) {
      return Center(
        child: Text(
          'No data available for ${selectedBatch} ${selectedYear} ${selectedSemester}',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    Set<String> dataColumns = {};
    for (var student in studentList) {
      dataColumns.addAll(student.keys.where((k) =>
      !['id', 'name', 'batch', 'year', 'semester', 'csrf_token'].contains(k) &&
          !k.endsWith('_date')));
    }

    List<String> sortedColumns = dataColumns.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        headingRowColor: MaterialStateProperty.all(Colors.purple.shade100),
        columns: [
          const DataColumn(label: Text("ID"), numeric: true),
          const DataColumn(label: Text("Name")),
          const DataColumn(label: Text("Batch")),
          const DataColumn(label: Text("Year")),
          const DataColumn(label: Text("Semester")),
          ...sortedColumns.map((field) => DataColumn(
            label: SizedBox(
              width: 150,
              child: Text(
                field.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )),
        ],
        rows: studentList.map((student) {
          final id = student['id'].toString();
          return DataRow(cells: [
            DataCell(Text(id)),
            DataCell(Text(student['name']?.toString() ?? '')),
            DataCell(Text(student['batch']?.toString() ?? '')),
            DataCell(Text(student['year']?.toString() ?? '')),
            DataCell(Text(student['semester']?.toString() ?? '')),
            ...sortedColumns.map((field) {
              final dateField = "${field}_date";
              final initialVal = student[field]?.toString() ?? '';
              final dateVal = student[dateField]?.toString() ?? '';

              if (selectedType?.toLowerCase() == "project") {
                return DataCell(
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: modifiedData[id]?[field]?.toString() ?? initialVal,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        modifiedData.putIfAbsent(id, () => {});
                        modifiedData[id]![field] = val;
                      },
                    ),
                  ),
                );
              } else {
                return DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: modifiedData[id]?[field] == "YES" || initialVal == "YES",
                        onChanged: (val) => setState(() => _updateCheckbox(id, field, val!)),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          initialValue: modifiedData[id]?[dateField] ?? dateVal,
                          decoration: const InputDecoration(
                            hintText: 'yyyy-mm-dd',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          ),
                          onChanged: (val) => _updateDate(id, dateField, val.trim()),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue, void Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey.shade900, Colors.grey.shade700]
              : [Colors.blueGrey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(items.first),
          onChanged: onChanged,
          items: items.skip(1).map((String value) {
            return DropdownMenuItem(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.grey.shade800, Colors.grey.shade600]
                        : [Colors.blueGrey.shade100, Colors.white],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.menu_book, size: 40, color: isDark ? Colors.white : Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        'NOTES & ASSIGNMENTS',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ]),
                    IconButton(
                      icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round,
                          color: isDark ? Colors.white : Colors.black),
                      onPressed: widget.toggleTheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: _buildDropdown(batches, selectedBatch, (val) => setState(() => selectedBatch = val)),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: _buildDropdown(years, selectedYear, (val) => setState(() => selectedYear = val)),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: _buildDropdown(semesters, selectedSemester, (val) => setState(() => selectedSemester = val)),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: _buildDropdown(types, selectedType, (val) => setState(() => selectedType = val)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchData,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text("Fetch Data", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              ),
              const SizedBox(height: 20),
              _buildDataTable(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Submit Changes", style: TextStyle(color: Colors.white)),
                onPressed: isLoading ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}