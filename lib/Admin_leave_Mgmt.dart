import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Admin_Leave_Page extends StatefulWidget {
  const Admin_Leave_Page({Key? key}) : super(key: key);

  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<Admin_Leave_Page> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allData = [];
  List<dynamic> filteredData = [];
  String filterStatus = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/Leave_Data.php');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            allData = json.decode(response.body);
            isLoading = false;
            _applyFilters();
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

  Future<void> _status(String reason, String startDate, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID') ?? '';
    final response = await http.post(
      Uri.parse('https://creativecollege.in/Flutter/Leave_status.php'),
      body: {
        'ID': userID.trim(),
        'reason': reason,
        'startdate': startDate,
        'Status': status,
      },
    );

    Fluttertoast.showToast(
      msg: response.body,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: status == 'Approved' ? Colors.green : Colors.redAccent,
      textColor: Colors.white,
    );
    fetchData();
  }

  void _applyFilters() {
    List<dynamic> tempData = allData;

    if (filterStatus != 'All') {
      tempData = tempData.where((item) => item['Status'] == filterStatus).toList();
    }

    if (searchController.text.isNotEmpty) {
      String searchText = searchController.text.toLowerCase();
      tempData = tempData
          .where((item) =>
          (item['Name'] ?? '').toString().toLowerCase().contains(searchText))
          .toList();
    }

    setState(() {
      filteredData = tempData;
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildStatusFilterChip(String status) {
    final isSelected = filterStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            filterStatus = selected ? status : 'All';
            _applyFilters();
          });
        },
        selectedColor: const Color(0xFF4F46E5),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1E293B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text(
              'Leave Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            floating: false,
            pinned: true,
            expandedHeight: 160,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 75, left: 16, right: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by staff name...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => _applyFilters(),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusFilterChip('All'),
                          _buildStatusFilterChip('Pending'),
                          _buildStatusFilterChip('Approved'),
                          _buildStatusFilterChip('Rejected'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: isLoading
                ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
            )
                : Padding(
              padding: const EdgeInsets.all(16),
              child: filteredData.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  var item = filteredData[index];
                  final statusColor = getStatusColor(item['Status'] ?? '');

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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['Name'] ?? 'Staff Member',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: statusColor,
                                  ),
                                ),
                                child: Text(
                                  item['Status'] ?? 'Pending',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Reason: ${item['Reason'] ?? '-'}',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.date_range_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                'Dates: ${item['Start_Date']} to ${item['Last_Date']}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          if (item['Status'] == 'Pending') ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    _status(
                                      item['Reason'],
                                      item['Start_Date'],
                                      'Rejected',
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  child: const Text('REJECT',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    _status(
                                      item['Reason'],
                                      item['Start_Date'],
                                      'Approved',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  child: const Text('APPROVE',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              )
                  : const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'No Leave Applications Found',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
