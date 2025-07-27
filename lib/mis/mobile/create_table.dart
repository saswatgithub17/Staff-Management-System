import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateTable extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CreateTable({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  State<CreateTable> createState() => _CreateTableState();
}

class _CreateTableState extends State<CreateTable> {
  String? selectedBatch;
  String? selectedYear;
  String? selectedSemester;
  int paperCount = 0;
  bool showSubjectInputs = false;

  List<String> batches = ['Batch', 'BCA', 'Bsc.cs', 'BBA'];
  List<String> years = ['Year', '2022-25', '2023-26', '2024-28'];
  List<String> semesters = [
    '1st Sem',
    '2nd Sem',
    '3rd Sem',
    '4th Sem',
    '5th Sem',
    '6th Sem',
    '7th Sem',
    '8th Sem'
  ];

  List<TextEditingController> subjectControllers = [];
  List<String?> selectedUnits = [];

  @override
  void dispose() {
    for (var controller in subjectControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDropdown(String hint, List<String> items, String? selectedValue,
      void Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          hint: Text(hint,
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w500)),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down,
              color: isDark ? Colors.white : Colors.black),
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNumberSpinner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('No Of Papers:',
              style: TextStyle(fontSize: 16, color: Colors.black)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.black),
                onPressed: () {
                  setState(() {
                    if (paperCount > 0) paperCount--;
                  });
                },
              ),
              Text(
                paperCount.toString(),
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  setState(() {
                    paperCount++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          showSubjectInputs = true;
          subjectControllers = List.generate(
              paperCount, (index) => TextEditingController());
          selectedUnits = List.generate(paperCount, (index) => null);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      child: Text(
        "NEXT",
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }


  Widget _buildSubjectInputs() {
    return Column(
      children: List.generate(paperCount, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Text("SUB-${index + 1}:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: subjectControllers[index],
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedUnits[index],
                hint: Text("Select No of Units"),
                items: List.generate(
                  10,
                      (unit) => DropdownMenuItem(
                    value: '${unit + 1}',
                    child: Text('${unit + 1}'),
                  ),
                ),
                onChanged: (value) {
                  setState(() => selectedUnits[index] = value);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: _submitData,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
      ),
      child: Text("Submit",
          style: TextStyle(
            color: isDark ? Colors.black : Colors.deepPurple,
          )),
    );
  }

  Future<void> _submitData() async {
    if (selectedBatch == null || selectedYear == null || selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select batch, year and semester')),
      );
      return;
    }

    List<Map<String, dynamic>> subjects = [];
    for (int i = 0; i < paperCount; i++) {
      final name = subjectControllers[i].text;
      final units = selectedUnits[i];

      if (name.isEmpty || units == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all subject names and units')),
        );
        return;
      }

      subjects.add({
        'name': name,
        'units': int.tryParse(units) ?? 0,
      });
    }

    final body = {
      'batch': selectedBatch,
      'year': selectedYear,
      'semester': selectedSemester,
      'subjects': subjects,
    };

    final url = Uri.parse('https://creativecollege.in/MIS/MIS/api/create_tables.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.grey.shade800, Colors.grey.shade600]
                    : [Colors.blueGrey.shade100, Colors.white],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book,
                        size: 40, color: isDark ? Colors.white : Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'NOTES & ASSIGNMENTS',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.wb_sunny : Icons.nightlight_round,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: widget.toggleTheme,
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: _buildDropdown('Batch', batches, selectedBatch,
                            (val) => setState(() => selectedBatch = val))),
                SizedBox(width: 8),
                Expanded(
                    child: _buildDropdown('Year', years, selectedYear,
                            (val) => setState(() => selectedYear = val))),
                SizedBox(width: 8),
                Expanded(
                    child: _buildDropdown('Semester', semesters,
                        selectedSemester,
                            (val) => setState(() => selectedSemester = val))),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _buildNumberSpinner(),
          ),
          SizedBox(height: 20),
          _buildNextButton(),
          if (showSubjectInputs) _buildSubjectInputs(),
          if (showSubjectInputs)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildSubmitButton(),
            ),
        ],
      ),
    );
  }
}