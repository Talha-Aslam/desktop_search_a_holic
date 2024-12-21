import 'package:flutter/material.dart';

class Invoice extends StatelessWidget {
  const Invoice({super.key});

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
        title: const Text('Invoice',
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
        child: ListView(
          children: [
            InvoiceItem(
              productName: 'Product 1',
              productPrice: '100',
              productQty: '2',
              productID: '1',
            ),
            InvoiceItem(
              productName: 'Product 2',
              productPrice: '200',
              productQty: '1',
              productID: '2',
            ),
            // Add more InvoiceItem widgets as needed
          ],
        ),
      ),
    );
  }
}

class InvoiceItem extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productQty;
  final String productID;

  const InvoiceItem({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productQty,
    required this.productID,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Card(
        color: Colors.white, // Background color
        elevation: 4.0,
        child: ListTile(
          title: Text(
            productName,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700), // Text color
          ),
          subtitle: Text(
            'Price: $productPrice, Quantity: $productQty',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
