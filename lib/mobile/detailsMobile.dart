import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:staff_task_management/mobile/mob_Profile.dart';
import 'package:staff_task_management/mobile/mob_add_task.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailsMobile extends StatefulWidget {
  @override
  _DetailsMobileState createState() => _DetailsMobileState();
}

class _DetailsMobileState extends State<DetailsMobile> {
  List<Task> tasks = [];
  late List<Task> originalTasks = [];
  TaskStatus filter = TaskStatus.all;
  DateTime selectedDate = DateTime.now();
  DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
  DateTime? selectedMonth;
  int selectedFilterIndex = 0;
  XFile? _pickedImage;
  late String pickedImagePath;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('pickedImagePath');

    setState(() {
      if (savedImagePath != null) {
        _pickedImage = XFile(savedImagePath);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    loadImagePath();
  }

  String name = '';
  String designation = '';

  Future<void> initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.get(
        Uri.parse('https://creativecollege.in/Flutter/Profile.php?id=$userID'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData is List && jsonData.isNotEmpty) {
        final firstElement = jsonData[0];
        setState(() {
          name = firstElement['name'];
        });
      } else {
        setState(() {
          name = 'Data not found';
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
    await fetchData();
    filterTasksToday();
  }

  TaskStatus taskStatusFromString(String status) {
    switch (status) {
      case 'Started':
        return TaskStatus.active;
      case 'Completed':
        return TaskStatus.completed;
      case 'Not Started':
        return TaskStatus.pending;
      default:
        return TaskStatus.all;
    }
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.get(Uri.parse(
        'https://creativecollege.in/Flutter/Task_Details.php?id=$userID'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        tasks = responseData.map((taskData) {
          return Task(
              taskData['TITLE'],
              taskStatusFromString(taskData['STATUS']),
              taskData['ADDDATE'],
              taskData['STARTDATE'],
              taskData['ENDDATE']);
        }).toList();
        originalTasks = List.from(tasks);
      });
    } else {
      throw Exception('Error while fetching data');
    }
  }

  void setFilter(TaskStatus newFilter) {
    setState(() {
      filter = newFilter;
      if (filter == TaskStatus.all) {
        tasks = List.from(originalTasks);
      }
    });
  }

  void filterTasksByDate(DateTime date) {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      selectedDate = date;
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.isAtSameMomentAs(date);
      }).toList();
    });
  }

  void filterTasksLastWeek() {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      lastWeek = DateTime.now().subtract(const Duration(days: 7));
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.isAfter(lastWeek) ||
            taskDate.isAtSameMomentAs(lastWeek);
      }).toList();
    });
  }

  void filterTasksToday() {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      selectedDate = DateTime.now();
      tasks = originalTasks.where((task) {
        final taskDate = DateTime.parse(task.date).toLocal();
        final todayStart = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, 0, 0, 0)
            .toLocal();
        final todayEnd = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, 23, 59, 59)
            .toLocal();
        return taskDate.isAtSameMomentAs(todayStart) ||
            (taskDate.isAfter(todayStart) && taskDate.isBefore(todayEnd));
      }).toList();
    });
  }

  void filterTasksByYear(int year) {
    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.year == year;
      }).toList();
    });
  }

  void filterTasksByMonth(DateTime? month) {
    if (month == null) {
      return;
    }

    setState(() {
      setFilter(TaskStatus.all);
      filter = TaskStatus.all;
      selectedMonth = month;
      tasks = originalTasks.where((task) {
        final taskDate = DateFormat("yyyy-MM-dd").parse(task.date);
        return taskDate.month == month.month && taskDate.year == month.year;
      }).toList();
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        filterTasksByDate(selectedDate);
      });
    }
  }

  void _selectMonth(BuildContext context) {
    DateTime now = DateTime.now();
    filterTasksByMonth(DateTime(now.year, now.month));
  }

  void _selectYear(BuildContext context) {
    int currentYear = DateTime.now().year;
    filterTasksByYear(currentYear);
  }

  void _navigateToAddTaskScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Mob_Add_Task()),
    );
  }

  Widget buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FadeInLeftBig(
          duration: const Duration(milliseconds: 1500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildFilterOption("Today", 0, () => filterTasksToday()),
              buildFilterOption("This Week", 1, () => filterTasksLastWeek()),
              buildFilterOption("This Month", 2, () {
                _selectMonth(context);
              }),
              buildFilterOption("This Year", 3, () {
                _selectYear(context);
              }),
              buildFilterOption("All", 4, () => setFilter(TaskStatus.all)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterOption(String label, int index, VoidCallback onPressed) {
    final isSelected = selectedFilterIndex == index;
    final bgColor = isSelected ? const Color(0xFF2563EB) : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 3 : 1,
        shadowColor: isSelected ? Colors.blue.withOpacity(0.3) : Colors.black12,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedFilterIndex = index;
            });
            onPressed();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF0F172A),
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Work Details',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 300,
        backgroundColor: Colors.grey[100],
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade400]),
              ),
              child: Center(
                child: Text(
                  'Filter Tasks',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem("All Tasks", Icons.list, TaskStatus.all),
                  _buildDrawerItem("Active", Icons.play_arrow, TaskStatus.active),
                  _buildDrawerItem("Pending", Icons.pending, TaskStatus.pending),
                  _buildDrawerItem("Completed", Icons.check_circle, TaskStatus.completed),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _navigateToAddTaskScreen(context);
        },
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, TaskStatus status) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title,
          style: TextStyle(
              color: filter == status ? Colors.blue : Colors.black87,
              fontWeight: filter == status ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        setFilter(status);
        Navigator.pop(context);
      },
      tileColor: filter == status ? Colors.blue.withOpacity(0.1) : null,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFilterOptions(),
          const SizedBox(height: 20),
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
    );
  }

  Widget _buildTaskItem(Task task) {
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case TaskStatus.active:
        statusColor = Colors.orange;
        statusIcon = Icons.play_arrow;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.pending:
        statusColor = Colors.red;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today, 'Added: ${task.date}'),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.timer, 'Start: ${task.startDate}'),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.timer_off, 'End: ${task.endDate}'),
              const SizedBox(height: 8),
              _buildStatusChip(task.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case TaskStatus.active:
        chipColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case TaskStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case TaskStatus.pending:
        chipColor = Colors.red;
        statusText = 'Pending';
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Chip(
        backgroundColor: chipColor.withOpacity(0.1),
        label: Text(
          statusText,
          style: TextStyle(color: chipColor),
        ),
        avatar: Icon(Icons.circle, color: chipColor, size: 12),
      ),
    );
  }
}

class Task {
  final String title;
  final TaskStatus status;
  final String date;
  final String startDate;
  final String endDate;

  Task(this.title, this.status, this.date, this.startDate, this.endDate);
}

enum TaskStatus { active, completed, pending, all }