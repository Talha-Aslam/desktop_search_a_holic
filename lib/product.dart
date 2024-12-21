import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadDummyProducts();
  }

  void _loadDummyProducts() {
    // Dummy data for products
    var dummyProducts = [
      {"name": "Product 1", "price": 100, "quantity": 10},
      {"name": "Product 2", "price": 200, "quantity": 5},
      {"name": "Product 3", "price": 150, "quantity": 20},
    ];

    setState(() {
      products = dummyProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']),
            subtitle: Text(
                'Price: ${products[index]['price']}, Quantity: ${products[index]['quantity']}'),
          );
        },
      ),
    );
  }
}
