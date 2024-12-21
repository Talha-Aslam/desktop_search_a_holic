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
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, const Color.fromARGB(255, 73, 206, 195)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
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
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
              child: Card(
                color: Colors.white, // Background color
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    products[index]['name'],
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700), // Text color
                  ),
                  subtitle: Text(
                    'Price: ${products[index]['price']}, Quantity: ${products[index]['quantity']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
