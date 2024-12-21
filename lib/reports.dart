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
        title: const Text('Reports'),
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(reports[index]['title']),
                      subtitle: Text(reports[index]['description']),
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
