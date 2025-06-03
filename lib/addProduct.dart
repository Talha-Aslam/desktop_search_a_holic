// Add Product Page

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/firebase_service.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProduct createState() => _AddProduct();
}

class _AddProduct extends State<AddProduct> {
  // Controllers for the TextFields
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _productPrice = TextEditingController();
  final TextEditingController _productQty = TextEditingController();
  final TextEditingController _productType = TextEditingController();
  final TextEditingController _productCategory = TextEditingController();

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController dateinput = TextEditingController();
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    dateinput.text = "";
    super.initState();
  }

  void showAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Failed!',
      text: '${_productName.text} Failed to Add!',
    );
  }

  void showAlert1() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Added!",
      text: '${_productName.text} Product Added Successfully!',
    );
  }

  Future<void> _saveProduct() async {
    if (!formkey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user for shop ID
      final user = _firebaseService.currentUser;
      String? shopId;
      
      // Get shop ID from user profile if available
      if (user != null) {
        try {
          final userData = await _firebaseService.getUserData(user.uid);
          if (userData.exists) {
            final data = userData.data() as Map<String, dynamic>;
            shopId = data['shopId'];
          }
        } catch (e) {
          print('Error getting shop ID: $e');
        }
      }
      
      // Create product data map
      Map<String, dynamic> productData = {
        'name': _productName.text.trim(),
        'price': double.parse(_productPrice.text.trim()),
        'quantity': double.parse(_productQty.text.trim()),
        'expiry': dateinput.text.trim(),
        'category': _productCategory.text.trim(),
        'type': _productType.text.trim(),
        'userEmail': _firebaseService.currentUser?.email ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Add shop ID to product data if available
      if (shopId != null && shopId.isNotEmpty) {
        productData['shopId'] = shopId;
      }

      // Save to Firestore using FirebaseService
      await _firebaseService.addProduct(productData);

      // Show success message
      showAlert1();

      // Clear all fields
      _clearForm();

      // Return success to parent page
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Failed!',
          text: 'Failed to add product: ${e.toString()}',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _productName.clear();
    _productPrice.clear();
    _productQty.clear();
    _productType.clear();
    _productCategory.clear();
    dateinput.clear();
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
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.scaffoldBackgroundColor,
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: themeProvider.cardBackgroundColor,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header with Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  size: 30,
                                  color: themeProvider.gradientColors[0],
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Add New Product",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Product Name
                            _buildTextField(
                              context,
                              'Product Name',
                              _productName,
                              Icons.inventory,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Product Name required';
                                } else {
                                  RegExp regExp = RegExp(
                                    r"^[a-zA-Z][a-zA-Z0-9\s]*$",
                                    caseSensitive: false,
                                    multiLine: false,
                                  );
                                  if (!regExp.hasMatch(value)) {
                                    return 'Please enter a valid Name';
                                  }
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Product Price
                            _buildTextField(
                              context,
                              'Product Price',
                              _productPrice,
                              Icons.price_check,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^\d+\.?\d{0,2}"))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Price required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Product Quantity
                            _buildTextField(
                              context,
                              'Product Quantity',
                              _productQty,
                              Icons.production_quantity_limits,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^\d+\.?\d{0,2}"))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Quantity required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Expiry Date
                            TextFormField(
                              controller: dateinput,
                              readOnly: true,
                              style: TextStyle(color: themeProvider.textColor),
                              decoration: InputDecoration(
                                labelText: "Expiry Date",
                                labelStyle:
                                    TextStyle(color: themeProvider.textColor),
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: themeProvider.gradientColors[0]),
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color: themeProvider.gradientColors[0]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: themeProvider.isDarkMode
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: themeProvider.gradientColors[0]
                                        .withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: themeProvider.gradientColors[0],
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select expiry date';
                                }
                                return null;
                              },
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: themeProvider.isDarkMode
                                            ? ColorScheme.dark(
                                                primary: themeProvider
                                                    .gradientColors[0],
                                              )
                                            : ColorScheme.light(
                                                primary: themeProvider
                                                    .gradientColors[0],
                                              ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  setState(() {
                                    dateinput.text = formattedDate;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Visibility Type
                            _buildDropdown(
                              context,
                              "Product Visibility",
                              Icons.visibility,
                              ["Public", "Private"],
                              (value) {
                                _productType.text = value.toString();
                              },
                              "Select Visibility",
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select visibility';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Product Category
                            _buildDropdown(
                              context,
                              "Product Category",
                              Icons.category,
                              [
                                "Medicine",
                                "Supplements",
                                "First Aid",
                                "Hygiene",
                                "Other"
                              ],
                              (value) {
                                _productCategory.text = value.toString();
                              },
                              "Select Category",
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select category';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Cancel Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  icon: const Icon(Icons.cancel_outlined),
                                  label: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Add Button
                                ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _saveProduct,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.add_circle_outline),
                                  label: Text(
                                    _isLoading ? "Adding..." : "Add",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        themeProvider.gradientColors[0],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build text fields with consistent styling
  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: themeProvider.textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: themeProvider.textColor),
        prefixIcon: Icon(icon, color: themeProvider.gradientColors[0]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor:
            themeProvider.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.gradientColors[0].withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.gradientColors[0],
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  // Helper method to build dropdown fields with consistent styling
  Widget _buildDropdown(
    BuildContext context,
    String label,
    IconData icon,
    List<String> items,
    void Function(dynamic) onChanged,
    String hint, {
    String? Function(dynamic)? validator,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: themeProvider.textColor),
        prefixIcon: Icon(icon, color: themeProvider.gradientColors[0]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor:
            themeProvider.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.gradientColors[0].withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.gradientColors[0],
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(color: themeProvider.textColor),
      dropdownColor: themeProvider.cardBackgroundColor,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      hint: Text(
        hint,
        style: TextStyle(
          color: themeProvider.textColor.withOpacity(0.7),
        ),
      ),
      icon: Icon(Icons.arrow_drop_down, color: themeProvider.gradientColors[0]),
    );
  }
}
