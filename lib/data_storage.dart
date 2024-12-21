import 'package:flutter/material.dart';

class DataStorage extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  String _password = "password"; // Default password

  List<Map<String, dynamic>> get products => _products;
  String get password => _password;

  void addProduct(Map<String, dynamic> product) {
    _products.add(product);
    notifyListeners();
  }

  void editProduct(String productID, Map<String, dynamic> updatedProduct) {
    int index = _products.indexWhere((product) => product['id'] == productID);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void changePassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }
}
