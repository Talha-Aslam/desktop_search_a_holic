import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/firebase_service.dart';
import 'package:quickalert/quickalert.dart';

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
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _originalProductData;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _productName.dispose();
    _productPrice.dispose();
    _productQty.dispose();
    _productType.dispose();
    _productCategory.dispose();
    _productExpiry.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Debug logging
      print('Attempting to load product with ID: ${widget.productID}');

      // Check if productID is valid
      if (widget.productID.isEmpty) {
        throw Exception('Product ID is empty');
      }

      // Check if this is a dummy product
      if (widget.productID.startsWith('dummy_')) {
        throw Exception(
            'This is demonstration data. Please add real products to edit them.');
      }

      Map<String, dynamic>? productData =
          await _firebaseService.getProduct(widget.productID);

      if (productData != null) {
        print('Product data loaded successfully: ${productData['name']}');
        setState(() {
          _originalProductData = productData;
          _productName.text = productData['name'] ?? '';
          _productPrice.text = productData['price']?.toString() ?? '';
          _productQty.text = productData['quantity']?.toString() ?? '';
          _productType.text = productData['type'] ?? 'Public';
          _productCategory.text = productData['category'] ?? '';
          _productExpiry.text = productData['expiry'] ?? '';
          _isLoading = false;
        });
      } else {
        // Product not found, show error and navigate back
        print('Product not found for ID: ${widget.productID}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found or access denied'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error loading product: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare updated product data
      Map<String, dynamic> updatedProductData = {
        'name': _productName.text.trim(),
        'price': double.tryParse(_productPrice.text) ?? 0.0,
        'quantity': int.tryParse(_productQty.text) ?? 0,
        'type': _productType.text.trim(),
        'category': _productCategory.text.trim(),
        'expiry': _productExpiry.text.trim(),
      };

      // Update product in Firebase
      await _firebaseService.updateProduct(
          widget.productID, updatedProductData);

      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Success",
          text: "Product updated successfully!",
        );

        // Navigate back to previous screen
        Navigator.pop(
            context, true); // Return true to indicate successful update
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "Failed to update product: ${e.toString()}",
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    // Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          backgroundColor: themeProvider.cardBackgroundColor,
          title: Text(
            'Delete Product',
            style: TextStyle(color: themeProvider.textColor),
          ),
          content: Text(
            'Are you sure you want to delete "${_productName.text}"? This action cannot be undone.',
            style: TextStyle(color: themeProvider.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: themeProvider.textColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        setState(() {
          _isSaving = true;
        });

        await _firebaseService.deleteProduct(widget.productID);

        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            text: "Product deleted successfully!",
          );

          Navigator.pop(
              context, true); // Return true to indicate successful deletion
        }
      } catch (e) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error",
            text: "Failed to delete product: ${e.toString()}",
          );
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
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
        ),
        body: Container(
          decoration: BoxDecoration(
            color: themeProvider.scaffoldBackgroundColor,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: themeProvider.gradientColors[0],
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading product data...',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            onPressed: _isSaving ? null : _deleteProduct,
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
                            onPressed: _isSaving ? null : _saveProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.gradientColors[0],
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: _isSaving
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'SAVING...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
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
