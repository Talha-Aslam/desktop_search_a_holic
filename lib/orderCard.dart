import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final String productName;
  final double productPrice;
  final double productQty;
  final String productID;

  const OrderCard({
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
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Dummy delete logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product removed from order')),
            );
          },
        ),
      ),
    );
  }
}
