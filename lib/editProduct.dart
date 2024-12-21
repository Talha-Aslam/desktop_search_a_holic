import 'package:flutter/material.dart';

class EditProduct extends StatefulWidget {
  final String productID;

  const EditProduct({super.key, required this.productID});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();
  final TextEditingController _productQty = TextEditingController();
  final TextEditingController _productType = TextEditingController();
  final TextEditingController _productCategory = TextEditingController();
  final TextEditingController _productExpiry = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load dummy data for the product
    _loadDummyProductData();
  }

  void _loadDummyProductData() {
    // Dummy data for the product
    var dummyProductData = {
      "id": widget.productID,
      "Name": "Dummy Product",
      "Price": "100",
      "Quantity": "10",
      "Type": "Public",
      "Expiry": "2023-12-31",
      "Category": "Tablet",
    };

    _productName.text = dummyProductData['Name']!;
    _productPrice.text = dummyProductData['Price']!;
    _productQty.text = dummyProductData['Quantity']!;
    _productType.text = dummyProductData['Type']!;
    _productCategory.text = dummyProductData['Category']!;
    _productExpiry.text = dummyProductData['Expiry']!;
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // Dummy save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully!')),
      );
    }
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
            'Edit Product',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productName,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productPrice,
                decoration: const InputDecoration(
                  labelText: 'Product Price',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productQty,
                decoration: const InputDecoration(
                  labelText: 'Product Quantity',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productType,
                decoration: const InputDecoration(
                  labelText: 'Product Type',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productCategory,
                decoration: const InputDecoration(
                  labelText: 'Product Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productExpiry,
                decoration: const InputDecoration(
                  labelText: 'Product Expiry Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product expiry date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor:
                      Colors.white.withOpacity(0.7), // Button text color
                ),
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
