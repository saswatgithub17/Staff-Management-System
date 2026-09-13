import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Contact_Edit extends StatefulWidget {
  final String course;
  final String sem;
  final String id;
  final String sMob;
  final String fMob;
  final String mMob;

  const Contact_Edit({
    Key? key,
    required this.course,
    required this.sem,
    required this.id,
    required this.sMob,
    required this.fMob,
    required this.mMob,
  }) : super(key: key);

  @override
  State<Contact_Edit> createState() => _Mob_Contact_Edit();
}

class _Mob_Contact_Edit extends State<Contact_Edit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController user;
  late TextEditingController course;
  late TextEditingController sem;
  late TextEditingController smob;
  late TextEditingController fmob;
  late TextEditingController mmob;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = TextEditingController(text: widget.id);
    course = TextEditingController(text: widget.course);
    sem = TextEditingController(text: widget.sem);
    smob = TextEditingController(text: widget.sMob);
    fmob = TextEditingController(text: widget.fMob);
    mmob = TextEditingController(text: widget.mMob);
  }

  @override
  void dispose() {
    user.dispose();
    course.dispose();
    sem.dispose();
    smob.dispose();
    fmob.dispose();
    mmob.dispose();
    super.dispose();
  }

  // Returns a map of the updated fields so the parent can refresh immediately
  Map<String, String> _getUpdatedData() {
    return {
      'course': course.text.trim(),
      'sem': sem.text.trim(),
      'smob': smob.text.trim(),
      'fmob': fmob.text.trim(),
      'mmob': mmob.text.trim(),
    };
  }

  Future<void> _Contact_Edit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://creativecollege.in/Flutter/Contact.php'),
        body: {
          'user': user.text.trim(),
          'course': course.text.trim(),
          'sem': sem.text.trim(),
          'smob': smob.text.trim(),
          'fmob': fmob.text.trim(),
          'mmob': mmob.text.trim(),
        },
      );

      // First check if response is JSON
      try {
        final responseData = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseData is Map && responseData.containsKey('success')) {
            if (responseData['success']) {
              Fluttertoast.showToast(
                msg: responseData['message'] ?? 'Contact updated successfully',
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
              // ✅ Pop with updated data so parent refreshes immediately
              Navigator.pop(context, _getUpdatedData());
            } else {
              throw Exception(responseData['message'] ?? 'Update failed');
            }
          } else {
            // Handle case where response is not in expected JSON format
            Fluttertoast.showToast(
              msg: response.body,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            // ✅ Pop with updated data so parent refreshes immediately
            Navigator.pop(context, _getUpdatedData());
          }
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      } catch (e) {
        // If JSON parsing fails, treat as plain text response
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: response.body,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // ✅ Pop with updated data so parent refreshes immediately
          Navigator.pop(context, _getUpdatedData());
        } else {
          throw Exception('Failed to update contact: ${response.body}');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Contact"),
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: <Widget>[
                FadeInUp(
                  duration: const Duration(milliseconds: 1800),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromRGBO(143, 148, 251, 1),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(143, 148, 251, .2),
                          blurRadius: 20.0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: user,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Student ID",
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: course,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter course';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              label: const Text('Course'),
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: sem,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter semester';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              label: const Text('Semester'),
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: smob,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter student mobile';
                              }
                              if (value.length != 10) {
                                return 'Enter valid 10-digit number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              label: const Text('Student Mobile'),
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: fmob,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length != 10) {
                                return 'Enter valid 10-digit number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              label: const Text('Father Mobile'),
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: mmob,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length != 10) {
                                return 'Enter valid 10-digit number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              label: const Text('Mother Mobile'),
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 1900),
                  child: InkWell(
                    onTap: _isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20.0),
                              ),
                              title: const Text(
                                "Confirm Edit",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              content: const Text(
                                "Are you sure you want to edit these contact details?",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _Contact_Edit();
                                  },
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Update Contact",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 2000),
                  child: const Text(
                    "Designed By Technocrat",
                    style: TextStyle(
                      color: Color.fromRGBO(143, 148, 251, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}