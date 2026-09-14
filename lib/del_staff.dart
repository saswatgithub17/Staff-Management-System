import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class StaffDelete extends StatefulWidget {
  const StaffDelete({Key? key}) : super(key: key);

  @override
  State<StaffDelete> createState() => _StaffDeleteState();
}

class _StaffDeleteState extends State<StaffDelete> {
  List<dynamic> items = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/staff_list.php');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            items = json.decode(response.body);
            items.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text(
              'Delete Staff',
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return FadeInLeft(
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: index * 50),
                    child: StaffDeleteCard(item: items[index], fetchData: fetchData),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffDeleteCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function fetchData;

  const StaffDeleteCard({Key? key, required this.item, required this.fetchData}) : super(key: key);

  Future<void> delete(String name) async {
    var url = Uri.parse(
        'https://creativecollege.in/Flutter/Delete_staff.php?name=$name');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        if (response.body.trim() == 'Success') {
          Fluttertoast.showToast(
            msg: 'Staff deleted successfully!',
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          fetchData();
        } else {
          Fluttertoast.showToast(
            msg: response.body,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? 'Staff Member';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFFEF2F2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['user_name'] ?? 'Staff ID',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 26),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      title: const Text(
                        "Confirm Delete",
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to delete $name?",
                        style: const TextStyle(color: Color(0xFF475569)),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            delete(name);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
