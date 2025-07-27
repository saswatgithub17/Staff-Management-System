// lib/mis/mobile/mis_home.dart
import 'package:flutter/material.dart';
import 'package:staff_task_management/mis/mobile/create_table.dart'; // Mobile version
import 'package:staff_task_management/mis/mobile/insert_data.dart';  // Mobile version
import 'package:staff_task_management/mis/mobile/generate_report.dart'; // Mobile version
import 'package:staff_task_management/mis/mobile/defaulters_list_page.dart'; // Mobile version
import 'package:staff_task_management/mis/mobile/cumulative_report.dart'; // Mobile version

class MISHome extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MISHome({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MISHome> createState() => _MISHomeState();
}

class _MISHomeState extends State<MISHome> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CreateTable(isDarkMode: widget.isDarkMode, toggleTheme: () {  },),
      InsertData(isDarkMode: widget.isDarkMode, toggleTheme: () {  },),
      GenerateReport(isDarkMode: widget.isDarkMode, toggleTheme: () {  },),
      DefaultersListPage(isDarkMode: widget.isDarkMode, toggleTheme: () {  },),
      CumulativeReportPage(isDarkMode: widget.isDarkMode, toggleTheme: () {  },),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS Mobile'),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Create Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Insert Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Defaulters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
        ],
      ),
    );
  }
}