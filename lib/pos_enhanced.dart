import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:desktop_search_a_holic/firebase_service.dart';
import 'package:desktop_search_a_holic/sales_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class POS extends StatefulWidget {
  const POS({super.key});

  @override
  _POSState createState() => _POSState();
}

class _POSState extends State<POS> {
  final FirebaseService _firebaseService = FirebaseService();
  final SalesService _salesService = SalesService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> cart = [];

  bool _isLoading = false;
  bool _advancedSearchVisible = false;
  bool _onlyInStock = false;
  double _subtotal = 0;
  double _discount = 0;
  double _tax = 0;
  double _total = 0;
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  String _selectedCategory = 'All';
  String _sortBy = 'name_asc'; // Default sort by name ascending
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _discountController.text = '0';
  }

  void _extractCategories() {
    Set<String> categoriesSet = {'All'};
    for (var product in products) {
      if (product['category'] != null) {
        categoriesSet.add(product['category'].toString());
      }
    }
    setState(() {
      _categories = categoriesSet.toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double subtotal = 0;
    for (var item in cart) {
      // Ensure price and quantity are properly converted to double
      double price = (item['price'] is int)
          ? (item['price'] as int).toDouble()
          : (item['price'] as double);
      int quantity = (item['quantity'] is double)
          ? (item['quantity'] as double).toInt()
          : (item['quantity'] as int);

      subtotal += price * quantity;
    }

    double discount = double.tryParse(_discountController.text) ?? 0;
    double tax = subtotal * 0.10; // 10% tax

    setState(() {
      _subtotal = subtotal;
      _discount = discount;
      _tax = tax;
      _total = subtotal + tax - discount;
    });
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> loadedProducts =
          await _firebaseService.getProducts();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        filteredProducts = loadedProducts;
        _isLoading = false;
      });

      _extractCategories();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Load dummy data as fallback
        _loadDummyProducts();
      }
    }
  }

  void _loadDummyProducts() {
    // Get current user email for dummy data
    String? userEmail = _firebaseService.currentUser?.email;

    // Dummy data for products with more details
    var dummyProducts = [
      {
        "id": "1",
        "name": "Paracetamol 500mg",
        "price": 100.0,
        "quantity": 100,
        "category": "Medicine",
        "expiry": "2025-12-31",
        "userEmail": userEmail,
      },
      {
        "id": "2",
        "name": "Aspirin 300mg",
        "price": 200.0,
        "quantity": 50,
        "category": "Medicine",
        "expiry": "2026-05-15",
        "userEmail": userEmail,
      },
      {
        "id": "3",
        "name": "Vitamins C",
        "price": 150.0,
        "quantity": 200,
        "category": "Supplements",
        "expiry": "2027-08-22",
        "userEmail": userEmail,
      },
      {
        "id": "4",
        "name": "Cough Syrup",
        "price": 85.0,
        "quantity": 30,
        "category": "Medicine",
        "expiry": "2025-10-30",
        "userEmail": userEmail,
      },
      {
        "id": "5",
        "name": "Bandages",
        "price": 50.0,
        "quantity": 100,
        "category": "First Aid",
        "expiry": "2028-01-01",
        "userEmail": userEmail,
      },
    ];

    setState(() {
      products = dummyProducts;
      filteredProducts = dummyProducts;
    });

    _extractCategories();
  }

  // Enhanced search with multiple filters
  void _searchProducts(String searchTerm) {
    if (searchTerm.isEmpty &&
        _selectedCategory == 'All' &&
        _minPrice == 0 &&
        _maxPrice == double.infinity) {
      setState(() {
        filteredProducts = List.from(products);
      });
      return;
    }

    final lowerCaseQuery = searchTerm.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        // Text search
        final name = product['name'].toString().toLowerCase();
        final category = product['category'].toString().toLowerCase();
        final textMatch =
            name.contains(lowerCaseQuery) || category.contains(lowerCaseQuery);

        // Category filter
        final categoryMatch = _selectedCategory == 'All' ||
            product['category'] == _selectedCategory;

        // Price range filter
        final price = (product['price'] is int)
            ? (product['price'] as int).toDouble()
            : (product['price'] as double);
        final priceMatch = price >= _minPrice && price <= _maxPrice;

        // Availability filter
        final quantity = (product['quantity'] is double)
            ? (product['quantity'] as double).toInt()
            : (product['quantity'] as int);
        final quantityMatch = !_onlyInStock || (quantity > 0);

        return textMatch && categoryMatch && priceMatch && quantityMatch;
      }).toList();

      // Apply sorting if needed
      if (_sortBy == 'name_asc') {
        filteredProducts.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
      } else if (_sortBy == 'name_desc') {
        filteredProducts.sort(
            (a, b) => b['name'].toString().compareTo(a['name'].toString()));
      } else if (_sortBy == 'price_asc') {
        filteredProducts.sort((a, b) {
          double priceA = (a['price'] is int)
              ? (a['price'] as int).toDouble()
              : (a['price'] as double);
          double priceB = (b['price'] is int)
              ? (b['price'] as int).toDouble()
              : (b['price'] as double);
          return priceA.compareTo(priceB);
        });
      } else if (_sortBy == 'price_desc') {
        filteredProducts.sort((a, b) {
          double priceA = (a['price'] is int)
              ? (a['price'] as int).toDouble()
              : (a['price'] as double);
          double priceB = (b['price'] is int)
              ? (b['price'] as int).toDouble()
              : (b['price'] as double);
          return priceB.compareTo(priceA);
        });
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    // Check current product quantity
    int currentQuantity = (product['quantity'] is double)
        ? (product['quantity'] as double).toInt()
        : (product['quantity'] as int);

    if (currentQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']} is out of stock'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if product is already in cart
    int index = cart.indexWhere((item) => item['id'] == product['id']);

    if (index != -1) {
      // Check if we can add more quantity
      int cartQuantity = (cart[index]['quantity'] is double)
          ? (cart[index]['quantity'] as double).toInt()
          : (cart[index]['quantity'] as int);

      if (cartQuantity >= currentQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cannot add more ${product['name']}. Only $currentQuantity available.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Product already in cart, increase quantity
      setState(() {
        cart[index]['quantity'] = cart[index]['quantity'] + 1;
      });
    } else {
      // Add new product to cart with quantity 1
      Map<String, dynamic> cartItem = Map<String, dynamic>.from(product);
      cartItem['quantity'] = 1;
      setState(() {
        cart.add(cartItem);
      });
    }

    _calculateTotal();

    // Display success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _updateCartItemQuantity(int index, int quantity) {
    if (quantity < 1) {
      return;
    }

    // Get the product from the main products list to check available quantity
    String productId = cart[index]['id'];
    Map<String, dynamic>? product = products.firstWhere(
      (p) => p['id'] == productId,
      orElse: () => {},
    );

    if (product.isNotEmpty) {
      int availableQuantity = (product['quantity'] is double)
          ? (product['quantity'] as double).toInt()
          : (product['quantity'] as int);

      if (quantity > availableQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Only $availableQuantity ${cart[index]['name']} available in stock'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      cart[index]['quantity'] = quantity;
    });

    _calculateTotal();
  }

  void _removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
    });

    _calculateTotal();
  }

  /// Update local product quantities after a successful sale
  void _updateLocalProductQuantity(String productId, int soldQuantity) {
    setState(() {
      // Update the main products list
      for (int i = 0; i < products.length; i++) {
        if (products[i]['id'] == productId) {
          int currentQuantity = (products[i]['quantity'] is double)
              ? (products[i]['quantity'] as double).toInt()
              : (products[i]['quantity'] as int);

          int newQuantity = currentQuantity - soldQuantity;
          if (newQuantity < 0) newQuantity = 0; // Prevent negative quantities

          products[i]['quantity'] = newQuantity;
          break;
        }
      }

      // Update the filtered products list
      for (int i = 0; i < filteredProducts.length; i++) {
        if (filteredProducts[i]['id'] == productId) {
          int currentQuantity = (filteredProducts[i]['quantity'] is double)
              ? (filteredProducts[i]['quantity'] as double).toInt()
              : (filteredProducts[i]['quantity'] as int);

          int newQuantity = currentQuantity - soldQuantity;
          if (newQuantity < 0) newQuantity = 0; // Prevent negative quantities

          filteredProducts[i]['quantity'] = newQuantity;
          break;
        }
      }
    });
  }

  Future<void> _processOrder() async {
    // Validate order
    if (cart.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart is empty. Please add products.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create order data
      Map<String, dynamic> orderData = {
        'customerName': _customerNameController.text.isEmpty
            ? 'Walk-in Customer'
            : _customerNameController.text.trim(),
        'customerPhone': _customerPhoneController.text.trim(),
        'items': cart
            .map((item) => {
                  'productId': item['id'],
                  'name': item['name'],
                  'price': (item['price'] is int)
                      ? (item['price'] as int).toDouble()
                      : (item['price'] as double),
                  'quantity': (item['quantity'] is double)
                      ? (item['quantity'] as double).toInt()
                      : (item['quantity'] as int),
                  'subtotal': ((item['price'] is int)
                          ? (item['price'] as int).toDouble()
                          : (item['price'] as double)) *
                      ((item['quantity'] is double)
                          ? (item['quantity'] as double).toInt()
                          : (item['quantity'] as int)),
                })
            .toList(),
        'subtotal': _subtotal,
        'discount': _discount,
        'tax': _tax,
        'total': _total,
        'date': DateTime.now().toIso8601String(),
        'userEmail': _firebaseService.currentUser?.email ?? '',
      };

      // Save to Firestore using SalesService
      await _salesService.addSale(orderData);

      // Update product quantities in inventory
      for (var item in cart) {
        if (!mounted) return; // Check mounted state in loop

        // Get the current product from inventory
        String productId = item['id'];
        int soldQuantity = (item['quantity'] is double)
            ? (item['quantity'] as double).toInt()
            : (item['quantity'] as int);

        try {
          // Update product quantity using SalesService
          await _salesService.updateProductInventory(productId, soldQuantity);

          if (!mounted) return; // Check again after async operation

          // Update local product quantities in real-time
          _updateLocalProductQuantity(productId, soldQuantity);
        } catch (e) {
          // Continue with the next item even if this one fails
          print('Failed to update inventory for product $productId: $e');
        }
      }

      if (!mounted) return; // Check before showing dialog

      // Show success message
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Order Complete",
        text:
            "Sale has been processed successfully!\nProduct quantities have been updated.",
      );

      if (!mounted) return; // Check before final setState

      // Clear the cart and customer info
      setState(() {
        cart.clear();
        _customerNameController.clear();
        _customerPhoneController.clear();
        _discountController.text = '0';
        _subtotal = 0;
        _discount = 0;
        _tax = 0;
        _total = 0;
      });
    } catch (e) {
      if (!mounted) return; // Check before showing error

      // Show error message
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to process order: ${e.toString()}",
      );
    } finally {
      if (mounted) {
        // Check before final setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Advanced search panel with filters
  Widget _buildAdvancedSearchPanel(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      color: themeProvider.cardBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Search Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Category filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeProvider.borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: Container(),
                        dropdownColor: themeProvider.cardBackgroundColor,
                        style: TextStyle(color: themeProvider.textColor),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                            _searchProducts(_searchController.text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Price range filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: themeProvider.textColor),
                            decoration: InputDecoration(
                              hintText: 'Min',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintStyle: TextStyle(
                                  color:
                                      themeProvider.textColor.withOpacity(0.5)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _minPrice = double.tryParse(value) ?? 0;
                              });
                              _searchProducts(_searchController.text);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(' - '),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: themeProvider.textColor),
                            decoration: InputDecoration(
                              hintText: 'Max',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintStyle: TextStyle(
                                  color:
                                      themeProvider.textColor.withOpacity(0.5)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _maxPrice = value.isEmpty
                                    ? double.infinity
                                    : (double.tryParse(value) ??
                                        double.infinity);
                              });
                              _searchProducts(_searchController.text);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Sorting options
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeProvider.borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        underline: Container(),
                        dropdownColor: themeProvider.cardBackgroundColor,
                        style: TextStyle(color: themeProvider.textColor),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'name_asc',
                            child: Text('Name (A-Z)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'name_desc',
                            child: Text('Name (Z-A)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'price_asc',
                            child: Text('Price (Low-High)'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'price_desc',
                            child: Text('Price (High-Low)'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortBy = newValue;
                            });
                            _searchProducts(_searchController.text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // In-stock filter
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: _onlyInStock,
                      activeColor: themeProvider.gradientColors[0],
                      onChanged: (bool? value) {
                        setState(() {
                          _onlyInStock = value ?? false;
                        });
                        _searchProducts(_searchController.text);
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Show in-stock items only',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Reset filters button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'All';
                    _minPrice = 0;
                    _maxPrice = double.infinity;
                    _sortBy = 'name_asc';
                    _onlyInStock = false;
                    _searchController.clear();
                  });
                  _searchProducts('');
                },
                icon:
                    Icon(Icons.refresh, color: themeProvider.gradientColors[0]),
                label: Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: themeProvider.gradientColors[0],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          'Point of Sale',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _advancedSearchVisible
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _advancedSearchVisible = !_advancedSearchVisible;
              });
            },
            tooltip: 'Advanced Filters',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProducts,
            tooltip: 'Refresh Products',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  // Advanced Search Panel
                  if (_advancedSearchVisible)
                    _buildAdvancedSearchPanel(themeProvider),

                  // Main Content
                  Expanded(
                    child: Row(
                      children: [
                        // Left side: Products list
                        Expanded(
                          flex: 3,
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            color: themeProvider.cardBackgroundColor,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: themeProvider.gradientColors[0],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      // Search Bar moved from AppBar
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: themeProvider.isDarkMode
                                                ? Colors.grey[800]
                                                : Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextField(
                                            controller: _searchController,
                                            onChanged: _searchProducts,
                                            style: TextStyle(
                                              color: themeProvider.textColor,
                                            ),
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Search medicines and products...',
                                              hintStyle: TextStyle(
                                                color: themeProvider.textColor
                                                    .withOpacity(0.6),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: themeProvider.iconColor,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _advancedSearchVisible
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                  color:
                                                      themeProvider.iconColor,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _advancedSearchVisible =
                                                        !_advancedSearchVisible;
                                                  });
                                                },
                                                tooltip: 'Advanced Search',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Products Header
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.inventory_2,
                                              color: themeProvider.iconColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Available Products',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: themeProvider.textColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: themeProvider
                                                    .gradientColors[0],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${filteredProducts.length}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      Expanded(
                                        child: filteredProducts.isEmpty
                                            ? Center(
                                                child: Text(
                                                  'No products found',
                                                  style: TextStyle(
                                                    color:
                                                        themeProvider.textColor,
                                                  ),
                                                ),
                                              )
                                            : GridView.builder(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1.3,
                                                  crossAxisSpacing: 12,
                                                  mainAxisSpacing: 12,
                                                ),
                                                itemCount:
                                                    filteredProducts.length,
                                                itemBuilder: (context, index) {
                                                  final product =
                                                      filteredProducts[index];
                                                  return _buildProductCard(
                                                      product, themeProvider);
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // Right side: Cart and checkout
                        Expanded(
                          flex: 2,
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            color: themeProvider.cardBackgroundColor,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Customer info
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Customer Information',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: themeProvider.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildTextField(
                                        controller: _customerNameController,
                                        labelText: 'Customer Name (Optional)',
                                        icon: Icons.person,
                                        themeProvider: themeProvider,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        controller: _customerPhoneController,
                                        labelText: 'Phone Number (Optional)',
                                        icon: Icons.phone,
                                        themeProvider: themeProvider,
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1),

                                // Cart items
                                Expanded(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart,
                                              color: themeProvider.iconColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Cart Items',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: themeProvider.textColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: themeProvider
                                                    .gradientColors[0],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${cart.length}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (cart.isNotEmpty)
                                              TextButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    cart.clear();
                                                    _calculateTotal();
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.remove_shopping_cart,
                                                    size: 16),
                                                label: const Text('Clear'),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: cart.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .shopping_cart_outlined,
                                                      size: 64,
                                                      color: themeProvider
                                                          .textColor
                                                          .withOpacity(0.3),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Cart is empty',
                                                      style: TextStyle(
                                                        color: themeProvider
                                                            .textColor
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Add products from the left panel',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: themeProvider
                                                            .textColor
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView.separated(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                itemCount: cart.length,
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const Divider(),
                                                itemBuilder: (context, index) {
                                                  return _buildCartItem(
                                                      index, themeProvider);
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Order summary and checkout
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Discount field
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller: _discountController,
                                              labelText: 'Discount Amount',
                                              icon: Icons.discount,
                                              themeProvider: themeProvider,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                _calculateTotal();
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Apply 10% discount
                                              double discount = _subtotal * 0.1;
                                              _discountController.text =
                                                  discount.toStringAsFixed(2);
                                              _calculateTotal();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: themeProvider
                                                  .gradientColors[0],
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('10% Off'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Order summary
                                      _buildSummaryRow(
                                          'Subtotal',
                                          _subtotal.toStringAsFixed(2),
                                          themeProvider),
                                      _buildSummaryRow(
                                          'Tax (10%)',
                                          _tax.toStringAsFixed(2),
                                          themeProvider),
                                      _buildSummaryRow(
                                          'Discount',
                                          _discount.toStringAsFixed(2),
                                          themeProvider,
                                          isDiscount: true),
                                      const Divider(thickness: 1),
                                      _buildSummaryRow(
                                          'Total',
                                          _total.toStringAsFixed(2),
                                          themeProvider,
                                          isTotal: true),

                                      const SizedBox(height: 16),

                                      // Checkout button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: cart.isEmpty || _isLoading
                                              ? null
                                              : _processOrder,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                themeProvider.gradientColors[0],
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const Text(
                                                  'Process Order',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      Map<String, dynamic> product, ThemeProvider themeProvider) {
    // Get current quantity for styling
    int currentQuantity = (product['quantity'] is double)
        ? (product['quantity'] as double).toInt()
        : (product['quantity'] as int);

    bool isOutOfStock = currentQuantity <= 0;
    bool isLowStock = currentQuantity > 0 && currentQuantity < 10;

    return Card(
      color: isOutOfStock
          ? (themeProvider.isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade300)
          : (themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.white),
      elevation: isOutOfStock ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Only allow adding to cart if product is in stock
          int currentQuantity = (product['quantity'] is double)
              ? (product['quantity'] as double).toInt()
              : (product['quantity'] as int);

          if (currentQuantity > 0) {
            _addToCart(product);
          } else {
            // Show out of stock message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product['name']} is out of stock'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category badge and icon in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        _getCategoryIcon(product['category']),
                        size: 24,
                        color: isOutOfStock
                            ? Colors.grey
                            : themeProvider.gradientColors[0],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Colors.grey
                              : _getCategoryColor(product['category']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['category'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Product name
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color:
                          isOutOfStock ? Colors.grey : themeProvider.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price and stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${((product['price'] is int) ? (product['price'] as int).toDouble() : (product['price'] as double)).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? Colors.grey
                              : themeProvider.gradientColors[0],
                          fontSize: 14,
                          decoration: isOutOfStock
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStockColor(currentQuantity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Out of Stock'
                              : (isLowStock
                                  ? 'Low: $currentQuantity'
                                  : 'Stock: $currentQuantity'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Add to cart button
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton.icon(
                      onPressed: currentQuantity > 0
                          ? () => _addToCart(product)
                          : null,
                      icon: Icon(
                          isOutOfStock ? Icons.block : Icons.add_shopping_cart,
                          size: 12),
                      label: Text(isOutOfStock ? 'Out of Stock' : 'Add',
                          style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOutOfStock
                            ? Colors.grey
                            : themeProvider.gradientColors[0],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Out of stock overlay
              if (isOutOfStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 32,
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

  Widget _buildCartItem(int index, ThemeProvider themeProvider) {
    final item = cart[index];

    // Ensure proper type handling for price and quantity
    final double price = (item['price'] is int)
        ? (item['price'] as int).toDouble()
        : (item['price'] as double);
    final int quantity = (item['quantity'] is double)
        ? (item['quantity'] as double).toInt()
        : (item['quantity'] as int);
    final double itemTotal = price * quantity;

    return Row(
      children: [
        // Quantity controls
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.grey.shade700
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () {
                  int currentQuantity = (item['quantity'] is double)
                      ? (item['quantity'] as double).toInt()
                      : (item['quantity'] as int);
                  _updateCartItemQuantity(index, currentQuantity - 1);
                },
                splashRadius: 20,
                tooltip: 'Decrease quantity',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  int currentQuantity = (item['quantity'] is double)
                      ? (item['quantity'] as double).toInt()
                      : (item['quantity'] as int);
                  _updateCartItemQuantity(index, currentQuantity + 1);
                },
                splashRadius: 20,
                tooltip: 'Increase quantity',
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: themeProvider.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '\$${price.toStringAsFixed(2)} × $quantity = \$${itemTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: themeProvider.textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Delete button
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _removeFromCart(index),
          splashRadius: 20,
          tooltip: 'Remove item',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required ThemeProvider themeProvider,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: themeProvider.textColor),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
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
            color: themeProvider.gradientColors[0].withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.gradientColors[0],
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, String value, ThemeProvider themeProvider,
      {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: themeProvider.textColor,
            ),
          ),
          Text(
            isDiscount ? '-\$$value' : '\$$value',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isDiscount
                  ? Colors.red
                  : (isTotal
                      ? themeProvider.gradientColors[0]
                      : themeProvider.textColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'medicine':
        return Colors.blue;
      case 'supplements':
        return Colors.green;
      case 'first aid':
        return Colors.red;
      case 'hygiene':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medicine':
        return Icons.medication;
      case 'supplements':
        return Icons.fitness_center;
      case 'first aid':
        return Icons.healing;
      case 'hygiene':
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }

  Color _getStockColor(int quantity) {
    if (quantity <= 0) {
      return Colors.red;
    } else if (quantity < 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
