import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:animate_do/animate_do.dart';

const _color1 = Color(0xFF0F172A);
var bgColor = const Color(0xFFF8FAFC);

class Mob_Add_Task extends StatefulWidget {
  const Mob_Add_Task({Key? key}) : super(key: key);

  @override
  State<Mob_Add_Task> createState() => _MobAddTaskState();
}

class _MobAddTaskState extends State<Mob_Add_Task> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late String userID = '';

  Future<void> retrieveStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? '';
  }

  @override
  void initState() {
    super.initState();
    retrieveStoredData().then((_) {
      setState(() {});
    });
  }

  Future<void> _addTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    late String user = prefs.getString('userID') ?? '';
    final response = await http.post(
      Uri.parse('https://creativecollege.in/Flutter/AddTask.php'),
      body: {
        'TITLE': titleController.text,
        'DESCRIPTION': descriptionController.text,
        'userID': user,
      },
    );
    if (response.statusCode == 200) {
      if (response.body == 'Success') {
        Fluttertoast.showToast(
          msg: 'WORK ADDED',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        descriptionController.text = '';
        titleController.text = '';
      } else {
        Fluttertoast.showToast(
          msg: 'Failed Loading',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
      slivers: <Widget>[
      SliverAppBar(
      expandedHeight: 100.0,
      backgroundColor: _color1,
      floating: false,
      pinned: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'ADD WORKS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
    ),
    SliverToBoxAdapter(
    child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const SizedBox(height: 20),
    FadeInUp(
    duration: Duration(milliseconds: 2000),
    child: Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.3),
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(0, 3),
    ),
    ],
    ),
    child: TextFormField(
    controller: titleController,
    decoration: InputDecoration(
    labelText: 'Enter Title Of Work',
    labelStyle: TextStyle(color: Colors.grey),
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(vertical: 0),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your Title';
    }
    return null;
    },
    ),
    ),
    ),
    const SizedBox(height: 20),
    FadeInUp(
    duration: Duration(milliseconds: 2000),
    child: Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.3),
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(0, 3),
    ),
    ],
    ),
    child: TextFormField(
    controller: descriptionController,
    maxLines: 4,
    decoration: InputDecoration(
    labelText: 'Enter Description Of Work',
    labelStyle: TextStyle(color: Colors.grey),
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(vertical: 5),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your Description';
    }
    return null;
    },
    ),
    ),
    ),
    const SizedBox(height: 20),
    FadeInUp(
    duration: Duration(milliseconds: 2000),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    FadeInRight(
    duration: Duration(milliseconds: 2000),
    child: ElevatedButton(
    onPressed: () {
    if (titleController.text.isEmpty) {
    Fluttertoast.showToast(
    msg: 'TITLE IS EMPTY',
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    );
    } else {
    showDialog(
    context: context,
    builder: (BuildContext context) {
    return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    ),
    title: Text(
    "Confirm Add Task",
    style: TextStyle(
    color: Colors.black,
    ),
    ),
    content: Text(
    "Are you sure you want to add this Task?",
    style: TextStyle(
    color: Colors.black,
    ),
    ),
    actions: <Widget>[
    TextButton(
    onPressed: () {
    Navigator.of(context).pop();
    },
    child: Text(
    "Cancel",
    style: TextStyle(
    color: Colors.blue,
    ),
    ),
    ),
    TextButton(
    onPressed: () {
    _addTask();
    Navigator.of(context).pop();
    },
    child: Text(
    "Confirm",
    style: TextStyle(
    color: Colors.black,
    ),
    ),
    ),
    ],
    );
    },
    );
    }
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    minimumSize: const Size(100.0, 50.0),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(13),
    ),
    ),
    child: const Text(
    'Add',
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: Colors.white),
    ),
    ),
    ),
    FadeInLeft(
    duration: Duration(milliseconds: 2000),
    child: ElevatedButton(
    onPressed: () {
    titleController.clear();
    descriptionController.clear();
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    minimumSize: const Size(100.0, 50.0),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(13),
    ),
    ),
    child: const Text(
    'Clear',
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: Colors.white),
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
      ],
      ),
    );
  }
}