import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Admin_ADD_WORK extends StatefulWidget {
  const Admin_ADD_WORK({Key? key}) : super(key: key);

  @override
  State<Admin_ADD_WORK> createState() => _Admin_ADD_WORK_State();
}

class _Admin_ADD_WORK_State extends State<Admin_ADD_WORK> {
  List<dynamic> items = [];
  String? selectedStaff;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/staff_list.php');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            items = json.decode(response.body);
            items.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
            selectedStaff = items.isNotEmpty ? items[0]['name'] : null;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _addTask() async {
    if (selectedStaff == null || selectedStaff!.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a staff member');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://creativecollege.in/Flutter/Admin_Add_Task.php'),
        body: {
          'TITLE': titleController.text.trim(),
          'DESCRIPTION': descriptionController.text.trim(),
          'Name': selectedStaff!.trim(),
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == 'Success') {
          Fluttertoast.showToast(
            msg: 'WORK ASSIGNED SUCCESSFULLY',
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          titleController.clear();
          descriptionController.clear();
        } else {
          Fluttertoast.showToast(
            msg: response.body,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
          );
        }
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Connection error',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text(
              'Assign Work',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            floating: false,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    // Card Form Container
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF64748B).withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Staff Member",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Staff Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedStaff,
                                hint: const Text("Select Staff"),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedStaff = newValue;
                                  });
                                },
                                items: items.map<DropdownMenuItem<String>>((dynamic item) {
                                  return DropdownMenuItem<String>(
                                    value: item['name'],
                                    child: Text(item['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title Field
                          TextFormField(
                            controller: titleController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter Work Title';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Title of Work',
                              hintText: 'Enter title',
                              prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFFD97706)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description Field
                          TextFormField(
                            controller: descriptionController,
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter Description';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Description of Work',
                              hintText: 'Enter work details & instructions',
                              prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFD97706)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              titleController.clear();
                              descriptionController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE2E8F0),
                              foregroundColor: const Color(0xFF1E293B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text('Assign Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
