// ignore_for_file: unrelated_type_equality_checks, prefer_interpolation_to_compose_strings, prefer_const_constructors, must_be_immutable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:desktop_search_a_holic/editProduct.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final double productPrice;
  final double productQty;
  final String productID;

  const ProductCard({
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
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(productID: productID),
              ),
            );
          },
        ),
      ),
    );
  }
}
