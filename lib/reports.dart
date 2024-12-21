import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:desktop_search_a_holic/sidebar.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadDummyReports();
  }

  void _loadDummyReports() {
    // Dummy data for reports
    var dummyReports = [
      {"title": "Report 1", "description": "This is the first report."},
      {"title": "Report 2", "description": "This is the second report."},
      {"title": "Report 3", "description": "This is the third report."},
    ];

    setState(() {
      reports = dummyReports;
    });
  }

  void _showReportDetails(String title, String description) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: title,
      text: description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, const Color.fromARGB(255, 73, 206, 195)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Reports',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlueAccent,
                    const Color.fromARGB(141, 178, 255, 89)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white, // Background color
                    elevation: 4.0,
                    child: ListTile(
                      title: Text(
                        reports[index]['title'],
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700), // Text color
                      ),
                      subtitle: Text(
                        reports[index]['description'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      onTap: () => _showReportDetails(
                        reports[index]['title'],
                        reports[index]['description'],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
