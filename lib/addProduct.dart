// Add Product Page

// Path: lib\addProduct.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:desktop_search_a_holic/product.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:intl/intl.dart';

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
  bool isDarkMode = false;

  // Theme colors - Light Mode
  final lightPrimaryColor = const Color(0xFF3F51B5); // Indigo
  final lightAccentColor = const Color(0xFF00BCD4); // Cyan
  final lightBgColor1 = const Color(0xFF2196F3); // Blue
  final lightBgColor2 = const Color(0xFF4CAF50); // Green
  final lightCardColor = Colors.white.withOpacity(0.95);
  final lightTextColor = Colors.black87;
  final lightErrorColor = const Color(0xFFF44336); // Red
  final lightSuccessColor = const Color(0xFF4CAF50); // Green

  // Theme colors - Dark Mode
  final darkPrimaryColor = const Color(0xFF7986CB); // Light Indigo
  final darkAccentColor = const Color(0xFF26C6DA); // Light Cyan
  final darkBgColor1 = const Color(0xFF263238); // Dark BlueGrey
  final darkBgColor2 = const Color(0xFF1A2327); // Darker BlueGrey
  final darkCardColor =
      const Color(0xFF37474F).withOpacity(0.95); // BlueGrey dark shade
  final darkTextColor = Colors.white;
  final darkErrorColor = const Color(0xFFEF5350); // Light Red
  final darkSuccessColor = const Color(0xFF66BB6A); // Light Green

  // Get current theme colors
  Color get primaryColor => isDarkMode ? darkPrimaryColor : lightPrimaryColor;
  Color get accentColor => isDarkMode ? darkAccentColor : lightAccentColor;
  Color get bgColor1 => isDarkMode ? darkBgColor1 : lightBgColor1;
  Color get bgColor2 => isDarkMode ? darkBgColor2 : lightBgColor2;
  Color get cardColor => isDarkMode ? darkCardColor : lightCardColor;
  Color get textColor => isDarkMode ? darkTextColor : lightTextColor;
  Color get errorColor => isDarkMode ? darkErrorColor : lightErrorColor;
  Color get successColor => isDarkMode ? darkSuccessColor : lightSuccessColor;

  // Input Field Border
  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(15),
    );
  }

  // Input decoration theme
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: isDarkMode
          ? const Color(0xFF455A64).withOpacity(0.7)
          : Colors.white.withOpacity(0.9),
      enabledBorder: _buildBorder(accentColor.withOpacity(0.5), 1.5),
      focusedBorder: _buildBorder(primaryColor, 2.0),
      errorBorder: _buildBorder(errorColor, 1.5),
      focusedErrorBorder: _buildBorder(errorColor, 2.0),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      errorStyle: TextStyle(color: errorColor, fontWeight: FontWeight.bold),
      hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
    );
  }

  @override
  // Update State
  void initState() {
    dateinput.text = "";
    super.initState();
    // Check for dark theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness = MediaQuery.of(context).platformBrightness;
      setState(() {
        isDarkMode = brightness == Brightness.dark;
      });
    });
  }

  void showAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Failed!',
      text: '${_productName.text} Failed to Add!',
      confirmBtnColor: errorColor,
      backgroundColor: cardColor,
      titleColor: textColor,
      textColor: textColor,
    );
  }

  void showAlert1() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Added!",
      text: '${_productName.text} Product Added Successfully!',
      confirmBtnColor: successColor,
      backgroundColor: cardColor,
      titleColor: textColor,
      textColor: textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Check theme changes
    final brightness = MediaQuery.of(context).platformBrightness;
    if ((brightness == Brightness.dark) != isDarkMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isDarkMode = brightness == Brightness.dark;
        });
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor1, bgColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: formkey,
          child: Row(
            children: [
              const Sidebar(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: screenWidth * 0.72,
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.025),
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black45 : Colors.black26,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header with Icon
                          Container(
                            margin: EdgeInsets.only(
                                top: screenHeight * 0.02,
                                bottom: screenHeight * 0.035),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: screenHeight * 0.06,
                                  color: primaryColor,
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                Text(
                                  "Add New Product",
                                  style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: screenHeight * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: primaryColor.withOpacity(0.3),
                                        offset: const Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Container(
                                  width: screenWidth * 0.2,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [accentColor, primaryColor],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Product Name
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.012,
                                horizontal: screenWidth * 0.03),
                            child: TextFormField(
                              controller: _productName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                              decoration: _inputDecoration(
                                  'Product Name', Icons.inventory),
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
                          ),

                          // Two fields side by side - Price and Quantity
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.012,
                                horizontal: screenWidth * 0.03),
                            child: Row(
                              children: [
                                // Price field
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _productPrice,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                    ),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"^\d+\.?\d{0,2}"))
                                    ],
                                    decoration: _inputDecoration(
                                        'Product Price', Icons.price_check),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Price required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                // Quantity field
                                Expanded(
                                  child: TextFormField(
                                    controller: _productQty,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                    ),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"^\d+\.?\d{0,2}"))
                                    ],
                                    decoration: _inputDecoration(
                                        'Product Quantity',
                                        Icons.production_quantity_limits),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Quantity required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Expiry Date
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.012,
                                horizontal: screenWidth * 0.03),
                            child: TextField(
                              controller: dateinput,
                              readOnly: true,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: "Expiry Date",
                                labelStyle: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: primaryColor),
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color: primaryColor),
                                filled: true,
                                fillColor: isDarkMode
                                    ? const Color(0xFF455A64).withOpacity(0.7)
                                    : Colors.white.withOpacity(0.9),
                                enabledBorder: _buildBorder(
                                    accentColor.withOpacity(0.5), 1.5),
                                focusedBorder: _buildBorder(primaryColor, 2.0),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 20),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: isDarkMode
                                            ? ColorScheme.dark(
                                                primary: primaryColor,
                                                onPrimary: Colors.white,
                                                surface: darkCardColor,
                                                onSurface: Colors.white,
                                              )
                                            : ColorScheme.light(
                                                primary: primaryColor,
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black,
                                              ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: primaryColor,
                                          ),
                                        ),
                                        dialogBackgroundColor: isDarkMode
                                            ? darkCardColor
                                            : Colors.white,
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
                          ),

                          // Two fields side by side - Visibility and Category
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.012,
                                horizontal: screenWidth * 0.03),
                            child: Row(
                              children: [
                                // Visibility Dropdown
                                Expanded(
                                  child: DropdownButtonFormField(
                                    dropdownColor: isDarkMode
                                        ? darkCardColor
                                        : Colors.white,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Product Visibility",
                                      labelStyle: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      prefixIcon: Icon(Icons.visibility,
                                          color: primaryColor),
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? const Color(0xFF455A64)
                                              .withOpacity(0.7)
                                          : Colors.white.withOpacity(0.9),
                                      enabledBorder: _buildBorder(
                                          accentColor.withOpacity(0.5), 1.5),
                                      focusedBorder:
                                          _buildBorder(primaryColor, 2.0),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 20),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Public",
                                        child: Text("Public"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Private",
                                        child: Text("Private"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      _productType.text = value.toString();
                                    },
                                    hint: Text(
                                      "Select Visibility",
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: primaryColor),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                // Category Dropdown
                                Expanded(
                                  child: DropdownButtonFormField(
                                    dropdownColor: isDarkMode
                                        ? darkCardColor
                                        : Colors.white,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Product Category",
                                      labelStyle: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      prefixIcon: Icon(Icons.category,
                                          color: primaryColor),
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? const Color(0xFF455A64)
                                              .withOpacity(0.7)
                                          : Colors.white.withOpacity(0.9),
                                      enabledBorder: _buildBorder(
                                          accentColor.withOpacity(0.5), 1.5),
                                      focusedBorder:
                                          _buildBorder(primaryColor, 2.0),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 20),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Syrup",
                                        child: Text("Syrup"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Tablet",
                                        child: Text("Tablet"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Capsule",
                                        child: Text("Capsule"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Drops",
                                        child: Text("Drops"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Other",
                                        child: Text("Other"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      _productCategory.text = value.toString();
                                    },
                                    hint: Text(
                                      "Select Category",
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Buttons
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.03,
                                horizontal: screenWidth * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Cancel Button
                                SizedBox(
                                  width: screenWidth * 0.15,
                                  height: screenHeight * 0.06,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Product()));
                                    },
                                    icon: const Icon(Icons.cancel_outlined,
                                        color: Colors.white),
                                    label: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: errorColor,
                                      elevation: 8,
                                      shadowColor: errorColor.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.06),
                                // Add Button
                                SizedBox(
                                  width: screenWidth * 0.15,
                                  height: screenHeight * 0.06,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (formkey.currentState!.validate()) {
                                        showAlert1();
                                        _productName.clear();
                                        _productPrice.clear();
                                        _productQty.clear();
                                        _productType.clear();
                                        _productCategory.clear();
                                        dateinput.clear();
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline,
                                        color: Colors.white),
                                    label: const Text(
                                      "Add",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: successColor,
                                      elevation: 8,
                                      shadowColor:
                                          successColor.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
