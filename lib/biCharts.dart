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
        title: const Text('BI Charts'),
      ),
      body: Center(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: snapshot.data!.map((data) {
                        return ListTile(
                          title: Text(data['x']),
                          trailing: Text(data['y'].toString()),
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
    );
  }
}
