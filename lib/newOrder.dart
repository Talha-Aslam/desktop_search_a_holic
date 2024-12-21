import 'package:flutter/material.dart';

class NewOrder extends StatefulWidget {
  const NewOrder({super.key});

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> searchProducts = [];

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
      products.clear();
      searchProducts.clear();
      for (var product in dummyProducts) {
        searchProducts.add(product);
        products.add(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
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
