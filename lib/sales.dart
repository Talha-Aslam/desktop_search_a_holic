import 'package:flutter/material.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  List<Map<String, dynamic>> recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDummySalesData();
  }

  void _loadDummySalesData() {
    // Dummy data for recent orders
    var dummySalesData = [
      {
        "customerPhone": "123-456-7890",
        "saleDate": "2023-01-01",
        "saleAmount": 100.0,
        "saleId": "1"
      },
      {
        "customerPhone": "987-654-3210",
        "saleDate": "2023-01-02",
        "saleAmount": 200.0,
        "saleId": "2"
      },
      {
        "customerPhone": "555-555-5555",
        "saleDate": "2023-01-03",
        "saleAmount": 150.0,
        "saleId": "3"
      },
    ];

    setState(() {
      recentOrders = dummySalesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Customer Phone')),
            DataColumn(label: Text('Sale Date')),
            DataColumn(label: Text('Sale Amount')),
            DataColumn(label: Text('Sale ID')),
          ],
          rows: recentOrders.map((order) {
            return DataRow(cells: [
              DataCell(Text(order['customerPhone'].toString())),
              DataCell(Text(order['saleDate'].toString().split(" ")[0])),
              DataCell(Text(order['saleAmount'].toString())),
              DataCell(Text(order['saleId'].toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
