import 'package:flutter/material.dart';
import 'create_table.dart';
import 'insert_data.dart';
import 'generate_report.dart';
import 'defaulters_list_page.dart';
import 'cumulative_report.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  String _getImagePath(int index) {
    switch (index) {
      case 0:
        return 'assets/icon/create_table.png';
      case 1:
        return 'assets/icon/insert-data.png';
      case 2:
        return 'assets/icon/report.png';
      case 3:
        return 'assets/icon/defaulter.png';
      case 4:
        return 'assets/icon/analysis.png';
      default:
        return '';
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'Create Tables';
      case 1:
        return 'Insert Data';
      case 2:
        return 'Generate Report';
      case 3:
        return 'Defaulters Tracking';
      case 4:
        return 'Cumulative Analysis';
      default:
        return '';
    }
  }

  List<Widget> get _pages => [
    CreateTable(toggleTheme: widget.toggleTheme, isDarkMode: true,),
    InsertData(toggleTheme: widget.toggleTheme, isDarkMode: true,),
    GenerateReport(toggleTheme: widget.toggleTheme, isDarkMode: true,),
    DefaultersListPage(toggleTheme: widget.toggleTheme, isDarkMode: true,),
    CumulativeReportPage(toggleTheme: widget.toggleTheme, isDarkMode: true,),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.grey.shade400),
        child: Row(
          children: List.generate(5, (index) {
            bool isMiddle = index == 2;
            bool isSelected = _selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => _onItemTapped(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else
                      const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        _getImagePath(index),
                        width: isMiddle ? 40 : 24,
                        height: isMiddle ? 40 : 24,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        _getLabel(index),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
