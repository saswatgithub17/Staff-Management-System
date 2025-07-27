import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Admin_Leave_Page extends StatefulWidget {
  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<Admin_Leave_Page> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> allData = [];
  List<dynamic> filteredData = [];
  String filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var url = Uri.parse('https://creativecollege.in/Flutter/Leave_Data.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        allData = json.decode(response.body);
        _applyFilters();
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Error fetching data',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
      backgroundColor: Colors.green,
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
          item['Name'].toString().toLowerCase().contains(searchText))
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          status,
          style: TextStyle(fontSize: 12),
        ),
        selected: filterStatus == status,
        onSelected: (selected) {
          setState(() {
            filterStatus = selected ? status : 'All';
            _applyFilters();
          });
        },
        selectedColor: getStatusColor(status),
        labelStyle: TextStyle(
          color: filterStatus == status ? Colors.white : Colors.black,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            title: Text(
              'Leave Request',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            floating: false,
            pinned: true,
            expandedHeight: 170,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.only(top: 70, left: 12, right: 12),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => _applyFilters(),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 6),
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
            child: Padding(
              padding: EdgeInsets.all(10),
              child: filteredData.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  var item = filteredData[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Name: ${item['Name']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusColor(item['Status'])
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: getStatusColor(item['Status']),
                                  ),
                                ),
                                child: Text(
                                  item['Status'],
                                  style: TextStyle(
                                    color: getStatusColor(item['Status']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Reason: ${item['Reason']}',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'From: ${item['Start_Date']}',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To: ${item['Last_Date']}',
                            style: TextStyle(fontSize: 13),
                          ),
                          if (item['Status'] == 'Pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _status(
                                      item['Reason'],
                                      item['Start_Date'],
                                      'Rejected',
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10),
                                    minimumSize: Size(10, 30),
                                  ),
                                  child: Text('REJECT',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                SizedBox(width: 8),
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10),
                                    minimumSize: Size(10, 30),
                                  ),
                                  child: Text('APPROVE',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'No Leave Applications Found',
                    style:
                    TextStyle(fontSize: 14, color: Colors.black54),
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
