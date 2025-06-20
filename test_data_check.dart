import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_service.dart';
import 'lib/sales_service.dart';
import 'lib/reports_service.dart';

void main() async {
  print('Checking for real data in the system...');

  // Initialize Firebase services
  final firebaseService = FirebaseService();
  final salesService = SalesService();
  final reportsService = ReportsService();

  try {
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User logged in: ${user.email}');

      // Check products
      print('\n--- Checking Products ---');
      try {
        final products = await firebaseService.getProducts();
        print('Found ${products.length} products');
        if (products.isNotEmpty) {
          print(
              'First product: ${products.first['name']} - ID: ${products.first['id']}');
          // Check if it's dummy data
          if (products.first['id']?.toString().startsWith('dummy_') == true) {
            print('This appears to be dummy data');
          } else {
            print('This appears to be real data');
          }
        }
      } catch (e) {
        print('Error loading products: $e');
      }

      // Check sales
      print('\n--- Checking Sales ---');
      try {
        final sales = await salesService.getSales();
        print('Found ${sales.length} sales');
        if (sales.isNotEmpty) {
          print(
              'First sale: Customer: ${sales.first['customerName']}, Total: ${sales.first['total']}');
        }
      } catch (e) {
        print('Error loading sales: $e');
      }

      // Check reports
      print('\n--- Checking Reports ---');
      try {
        final reports = await reportsService.getAllReports();
        print('Generated ${reports.length} reports');
        for (var report in reports) {
          print('${report['title']}: ${report['data']}');
        }
      } catch (e) {
        print('Error generating reports: $e');
      }
    } else {
      print('No user logged in');
    }
  } catch (e) {
    print('Error: $e');
  }
}
