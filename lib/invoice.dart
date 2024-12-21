import 'package:flutter/material.dart';

class Invoice extends StatelessWidget {
  const Invoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
      ),
      body: ListView(
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
          // Add more dummy invoice items as needed
        ],
      ),
    );
  }
}

/// A modified instance of "orderCard", without the "delete" button
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
    return Card(
      child: ListTile(
        title: Text(productName),
        subtitle: Text('Price: $productPrice, Quantity: $productQty'),
      ),
    );
  }
}
