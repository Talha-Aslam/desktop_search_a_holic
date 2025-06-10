// This is a test function to simulate creating real sales data
// This demonstrates how the reports page would work with actual sales data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createTestSalesData() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser?.email == null) {
      print('No user logged in');
      return;
    }

    String userEmail = auth.currentUser!.email!;

    print('Creating test sales data for user: $userEmail');

    // Create sample sales data
    List<Map<String, dynamic>> testSales = [
      {
        'customerName': 'John Doe',
        'customerPhone': '123-456-7890',
        'items': [
          {
            'name': 'Paracetamol 500mg',
            'quantity': 2,
            'price': 5.99,
            'productId': 'prod1'
          },
          {
            'name': 'Vitamin C',
            'quantity': 1,
            'price': 12.99,
            'productId': 'prod2'
          },
        ],
        'subtotal': 24.97,
        'discount': 0.0,
        'tax': 2.50,
        'total': 27.47,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String(),
      },
      {
        'customerName': 'Jane Smith',
        'customerPhone': '987-654-3210',
        'items': [
          {
            'name': 'Aspirin 300mg',
            'quantity': 3,
            'price': 8.50,
            'productId': 'prod3'
          },
        ],
        'subtotal': 25.50,
        'discount': 2.00,
        'tax': 2.35,
        'total': 25.85,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
      {
        'customerName': 'Walk-in Customer',
        'customerPhone': '',
        'items': [
          {
            'name': 'Hand Sanitizer',
            'quantity': 2,
            'price': 4.99,
            'productId': 'prod4'
          },
          {
            'name': 'Face Mask Pack',
            'quantity': 1,
            'price': 15.99,
            'productId': 'prod5'
          },
        ],
        'subtotal': 25.97,
        'discount': 0.0,
        'tax': 2.60,
        'total': 28.57,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      },
    ];

    // Add the sales to Firestore
    for (var sale in testSales) {
      await firestore.collection('sales').add(sale);
      print(
          '✅ Added test sale for ${sale['customerName']}: \$${sale['total']}');
    }

    print('✅ Test sales data created successfully!');
    print(
        '🔄 Now the reports page should show REAL DATA instead of dummy data');
  } catch (e) {
    print('❌ Error creating test sales data: $e');
  }
}

// Also create some test products to make the system more realistic
Future<void> createTestProducts() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    if (auth.currentUser?.email == null) {
      print('No user logged in');
      return;
    }

    String userEmail = auth.currentUser!.email!;

    print('Creating test product data for user: $userEmail');

    List<Map<String, dynamic>> testProducts = [
      {
        'name': 'Paracetamol 500mg',
        'price': 5.99,
        'quantity': 100,
        'category': 'Medicine',
        'expiry': '2025-12-31',
        'type': 'Public',
        'userEmail': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Vitamin C',
        'price': 12.99,
        'quantity': 50,
        'category': 'Supplements',
        'expiry': '2026-06-30',
        'type': 'Public',
        'userEmail': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Aspirin 300mg',
        'price': 8.50,
        'quantity': 75,
        'category': 'Medicine',
        'expiry': '2025-09-15',
        'type': 'Public',
        'userEmail': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Hand Sanitizer',
        'price': 4.99,
        'quantity': 200,
        'category': 'Hygiene',
        'expiry': '2026-03-01',
        'type': 'Public',
        'userEmail': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Face Mask Pack',
        'price': 15.99,
        'quantity': 30,
        'category': 'Safety',
        'expiry': '2027-01-01',
        'type': 'Public',
        'userEmail': userEmail,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Add the products to Firestore
    for (var product in testProducts) {
      await firestore.collection('products').add(product);
      print('✅ Added test product: ${product['name']} - \$${product['price']}');
    }

    print('✅ Test product data created successfully!');
  } catch (e) {
    print('❌ Error creating test product data: $e');
  }
}
