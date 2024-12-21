import 'package:flutter/material.dart';
import 'apicalls.dart';

class BiCharts extends StatefulWidget {
  const BiCharts({super.key});

  @override
  _BiChartsState createState() => _BiChartsState();
}

class _BiChartsState extends State<BiCharts> {
  late Future<List<Map<String, dynamic>>> _chartData;

  @override
  void initState() {
    super.initState();
    _chartData = ApiCall().getDummyChartData();
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
        title: const Text('BI Charts',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
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
        child: Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _chartData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading chart data');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No chart data available');
              } else {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.88,
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Card(
                    color: Colors.white, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: snapshot.data!.map((data) {
                          return ListTile(
                            title: Text(
                              data['x'],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700), // Text color
                            ),
                            trailing: Text(
                              data['y'].toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
