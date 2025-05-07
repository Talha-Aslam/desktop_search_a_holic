import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Delete Product',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: themeProvider.cardBackgroundColor,
                  title: Text(
                    'Delete Product',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  content: Text(
                    'Are you sure you want to delete this product?',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: themeProvider.textColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product deleted')),
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: themeProvider.scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product header card
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.gradientColors[0].withOpacity(0.1),
                      themeProvider.gradientColors[1].withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.gradientColors[0].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: themeProvider.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.inventory,
                        size: 30,
                        color: themeProvider.gradientColors[0],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product ID: ${widget.productID}',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _productName.text,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                          Text(
                            'Category: ${_productCategory.text}',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit product form
              Card(
                color: themeProvider.cardBackgroundColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _productName,
                          labelText: 'Product Name',
                          icon: Icons.shopping_bag,
                          themeProvider: themeProvider,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _productPrice,
                                labelText: 'Price',
                                icon: Icons.attach_money,
                                themeProvider: themeProvider,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _productQty,
                                labelText: 'Quantity',
                                icon: Icons.inventory_2,
                                themeProvider: themeProvider,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter quantity';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _productType,
                          labelText: 'Product Type',
                          icon: Icons.category,
                          themeProvider: themeProvider,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _productCategory,
                          labelText: 'Product Category',
                          icon: Icons.folder,
                          themeProvider: themeProvider,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _productExpiry,
                          labelText: 'Product Expiry Date',
                          icon: Icons.calendar_today,
                          themeProvider: themeProvider,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the product expiry date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.gradientColors[0],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required ThemeProvider themeProvider,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
        prefixIcon: Icon(
          icon,
          color: themeProvider.gradientColors[0],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: themeProvider.gradientColors[0]),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: themeProvider.gradientColors[0], width: 2),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.shade50,
      ),
      style: TextStyle(color: themeProvider.textColor),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
