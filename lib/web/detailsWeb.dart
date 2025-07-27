import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailsWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  late List<Task> originalTasks = [];
  TaskStatus filter = TaskStatus.all;
  DateTime selectedDate = DateTime.now();
  DateTime lastWeek = DateTime.now().subtract(Duration(days: 7));
  DateTime? selectedMonth;
  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
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
      lastWeek = DateTime.now().subtract(Duration(days: 7));
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

  void _selectMonth(BuildContext context) async {
    DateTime? picked = await showMonthPicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      filterTasksByMonth(picked);
    }
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterOption("Today", 0, () => filterTasksToday()),
          SizedBox(width: 10),
          _buildFilterOption("This Week", 1, () => filterTasksLastWeek()),
          SizedBox(width: 10),
          _buildFilterOption("This Month", 2, () => _selectMonth(context)),
          SizedBox(width: 10),
          _buildFilterOption("All", 3, () => setFilter(TaskStatus.all)),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, int index, VoidCallback onPressed) {
    final isSelected = selectedFilterIndex == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedFilterIndex = index;
        });
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black, backgroundColor: isSelected ? Colors.blue : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue),
        ),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Manager',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20)),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterOption(
                  label: 'All',
                  selected: filter == TaskStatus.all,
                  onTap: () => setFilter(TaskStatus.all),
                ),
                FilterOption(
                  label: 'Active',
                  selected: filter == TaskStatus.active,
                  onTap: () => setFilter(TaskStatus.active),
                ),
                FilterOption(
                  label: 'Pending',
                  selected: filter == TaskStatus.pending,
                  onTap: () => setFilter(TaskStatus.pending),
                ),
                FilterOption(
                  label: 'Completed',
                  selected: filter == TaskStatus.completed,
                  onTap: () => setFilter(TaskStatus.completed),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.calendar_today, color: Colors.blue),
                  onSelected: (choice) {
                    if (choice == 'Last Week') {
                      filterTasksLastWeek();
                    } else if (choice == 'Select Month') {
                      _selectMonth(context);
                    } else if (choice == 'Select Date') {
                      _selectDate(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Last Week', 'Select Month', 'Select Date'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TaskCount(taskStatus: TaskStatus.active, tasks: tasks),
                  TaskCount(taskStatus: TaskStatus.completed, tasks: tasks),
                  TaskCount(taskStatus: TaskStatus.pending, tasks: tasks),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: tasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 60, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No tasks found',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  if (filter != TaskStatus.all && task.status != filter) {
                    return Container();
                  }

                  String dateToShow = '';
                  if (task.status == TaskStatus.completed) {
                    dateToShow = task.endDate;
                  } else if (task.status == TaskStatus.active) {
                    dateToShow = task.startDate;
                  } else if (task.status == TaskStatus.pending) {
                    dateToShow = task.date;
                  }

                  return _buildTaskItem(task, dateToShow);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task, String dateToShow) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (task.status) {
      case TaskStatus.active:
        statusColor = Colors.orange;
        statusIcon = Icons.play_arrow;
        statusText = 'In Progress';
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case TaskStatus.pending:
        statusColor = Colors.red;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Unknown';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    dateToShow,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              backgroundColor: statusColor.withOpacity(0.1),
              label: Text(
                statusText,
                style: TextStyle(color: statusColor),
              ),
              avatar: Icon(Icons.circle, color: statusColor, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

enum TaskStatus { active, completed, pending, all }

class Task {
  final String name;
  final TaskStatus status;
  final String date;
  final String startDate;
  final String endDate;

  Task(this.name, this.status, this.date, this.startDate, this.endDate);
}

class FilterOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: selected ? Colors.white : Colors.black, backgroundColor: selected ? Colors.blue : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue),
        ),
      ),
      child: Text(label),
    );
  }
}

class TaskCount extends StatelessWidget {
  final TaskStatus taskStatus;
  final List<Task> tasks;

  TaskCount({required this.taskStatus, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final count = tasks.where((task) => task.status == taskStatus).length;

    Color statusColor;
    switch (taskStatus) {
      case TaskStatus.active:
        statusColor = Colors.orange;
        break;
      case TaskStatus.completed:
        statusColor = Colors.green;
        break;
      case TaskStatus.pending:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            taskStatus == TaskStatus.completed
                ? Icons.check_circle
                : taskStatus == TaskStatus.active
                ? Icons.play_arrow
                : Icons.pending,
            color: statusColor,
            size: 24,
          ),
        ),
        SizedBox(height: 5),
        Text(
          '$count',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        Text(
          taskStatus.toString().split('.').last.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54),
        ),
      ],
    );
  }
}