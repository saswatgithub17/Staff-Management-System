import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DefaultersListPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  const DefaultersListPage({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<DefaultersListPage> createState() => _DefaultersListPageState();
}

class _DefaultersListPageState extends State<DefaultersListPage> {
  String? selectedBatch, selectedYear, selectedSemester;
  String? selectedSubject = 'all';
  String? selectedType = 'all';

  bool showSubjectOptions = false;
  bool isLoading = false;

  // Updated batch names to match database
  List<String> batches = ['BCA', 'Bsc-c', 'BBA']; // Changed from 'Bsc.cs' to 'Bsc-c'
  List<String> years = ['2022-25', '2023-26', '2024-28'];
  List<String> semesters = [
    '1st Sem', '2nd Sem', '3rd Sem', '4th Sem',
    '5th Sem', '6th Sem', '7th Sem', '8th Sem'
  ];

  // Batch mapping to ensure correct database table names
  final Map<String, String> batchMap = {
    'BCA': 'bca',
    'Bsc-c': 'bsc-c', // Matches database table name
    'BBA': 'bba',
  };

  final Map<String, String> yearMap = {
    '2022-25': '2022-2025',
    '2023-26': '2023-2026',
    '2024-28': '2024-2028',
  };

  final Map<String, String> semesterMap = {
    '1st Sem': '1st_sem',
    '2nd Sem': '2nd_sem',
    '3rd Sem': '3rd_sem',
    '4th Sem': '4th_sem',
    '5th Sem': '5th_sem',
    '6th Sem': '6th_sem',
    '7th Sem': '7th_sem',
    '8th Sem': '8th_sem',
  };

  List<String> subjects = ['all'];
  List<String> types = ['all', 'notes', 'assignments'];

  List<Map<String, dynamic>> defaulters = [];

  Future<void> _loadSubjects() async {
    if ([selectedBatch, selectedYear, selectedSemester].contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select batch, year, and semester')),
      );
      return;
    }

    // Use batchMap to get correct database identifier
    final batch = batchMap[selectedBatch]!;
    final year = yearMap[selectedYear]!;
    final semester = semesterMap[selectedSemester]!;

    final url =
        'https://creativecollege.in/MIS/MIS/api/data/subjects.php?batch=$batch&year=$year&semester=$semester';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data.containsKey('subjects')) {
        final List<String> subjectList = List<String>.from(data['subjects'] ?? []);
        setState(() {
          subjects = ['all', ...subjectList];
          showSubjectOptions = true;
          defaulters.clear();
        });
      } else {
        throw Exception('Invalid API response: "subjects" key missing.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading subjects: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadDefaulters() async {
    if ([selectedBatch, selectedYear, selectedSemester].contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select batch, year, semester')),
      );
      return;
    }

    // Use batchMap to ensure correct database table name
    final batch = batchMap[selectedBatch]!;
    final year = yearMap[selectedYear]!;
    final semester = semesterMap[selectedSemester]!;

    final uri = Uri.parse('https://creativecollege.in/MIS/MIS/api/reports/defaulters_report.php').replace(
      queryParameters: {
        'batch': batch,
        'year': year,
        'semester': semester,
        'type': selectedType!,
        'subject': selectedSubject!,
      },
    );

    setState(() {
      isLoading = true;
      defaulters.clear();
    });

    try {
      final response = await http.get(uri);
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          defaulters = List<Map<String, dynamic>>.from(data['defaulters']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'No defaulters found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildDropdown(String hint, List<String> items, String? value, void Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
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
            value: value,
            hint: Text(hint, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaulterTable() {
    if (defaulters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No defaulters found for the selected criteria."),
      );
    }

    final List<String> columns = [];
    for (var d in defaulters) {
      for (var defaultEntry in d['defaults']) {
        final col = defaultEntry['column'] ?? '';
        if (!columns.contains(col)) {
          columns.add(col);
        }
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
        columns: [
          const DataColumn(label: Text("Roll No")),
          const DataColumn(label: Text("Name")),
          ...columns.map((c) => DataColumn(label: Text(c.split("_").take(2).join(" ")))),
        ],
        rows: defaulters.map((d) {
          final defaultsMap = <String, String>{};
          for (var defaultEntry in d['defaults']) {
            final col = defaultEntry['column'];
            defaultsMap[col] = defaultEntry['status'];
          }

          return DataRow(cells: [
            DataCell(Text(d['id'] ?? '')),
            DataCell(Text(d['name'] ?? '')),
            ...columns.map((col) => DataCell(Text(defaultsMap[col] ?? ''))),
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.grey.shade800, Colors.grey.shade600]
                    : [Colors.blueGrey.shade100, Colors.white],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 40, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 10),
                    Text('DEFAULTERS LIST',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18,
                            color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                IconButton(
                  icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed: widget.toggleTheme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildDropdown('Batch', batches, selectedBatch, (v) => setState(() => selectedBatch = v)),
                const SizedBox(width: 8),
                _buildDropdown('Year', years, selectedYear, (v) => setState(() => selectedYear = v)),
                const SizedBox(width: 8),
                _buildDropdown('Semester', semesters, selectedSemester, (v) => setState(() => selectedSemester = v)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _loadSubjects,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Load Subjects", style: TextStyle(color: Colors.white)),
          ),

          if (showSubjectOptions) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildDropdown('Subject', subjects, selectedSubject, (v) => setState(() => selectedSubject = v)),
                  const SizedBox(width: 8),
                  _buildDropdown('Type', types, selectedType, (v) => setState(() => selectedType = v)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _loadDefaulters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("Show Defaulters", style: TextStyle(color: Colors.white)),
            ),
          ],

          const SizedBox(height: 30),
          if (!isLoading) _buildDefaulterTable(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
