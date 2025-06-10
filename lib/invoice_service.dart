import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class InvoiceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Get recent invoices (from sales data)
  Future<List<Map<String, dynamic>>> getRecentInvoices({int limit = 10}) async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }

      // Query without orderBy to avoid composite index requirement
      // We'll sort the results in memory instead
      QuerySnapshot salesSnapshot = await _firestore
          .collection('sales')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
          .get();

      List<Map<String, dynamic>> invoices = [];

      for (var doc in salesSnapshot.docs) {
        Map<String, dynamic> saleData = doc.data() as Map<String, dynamic>;

        // Convert sale to invoice format
        Map<String, dynamic> invoice = {
          'id': doc.id,
          'invoiceNumber': 'INV-${doc.id.substring(0, 8).toUpperCase()}',
          'customerName': saleData['customerName'] ?? 'Walk-in Customer',
          'customerPhone': saleData['customerPhone'] ?? 'N/A',
          'date': saleData['createdAt'] != null
              ? (saleData['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          'items': saleData['items'] ?? [],
          'subtotal': saleData['subtotal']?.toDouble() ?? 0.0,
          'tax': saleData['tax']?.toDouble() ?? 0.0,
          'discount': saleData['discount']?.toDouble() ?? 0.0,
          'total': saleData['total']?.toDouble() ?? 0.0,
          'status': 'PAID', // Assume all sales are paid
          'paymentMethod': saleData['paymentMethod'] ?? 'Cash',
        };

        invoices.add(invoice);
      }

      // Sort by date in memory (most recent first)
      invoices.sort((a, b) => b['date'].compareTo(a['date']));

      // Apply limit after sorting
      if (limit > 0 && invoices.length > limit) {
        invoices = invoices.sublist(0, limit);
      }

      return invoices;
    } catch (e) {
      rethrow;
    }
  }

  // Get a specific invoice by sale ID
  Future<Map<String, dynamic>?> getInvoiceById(String saleId) async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }

      DocumentSnapshot doc =
          await _firestore.collection('sales').doc(saleId).get();

      if (!doc.exists) {
        return null;
      }

      Map<String, dynamic> saleData = doc.data() as Map<String, dynamic>;

      // Check if this sale belongs to current user
      if (saleData['userEmail'] != _auth.currentUser!.email) {
        throw Exception('Access denied');
      }

      return {
        'id': doc.id,
        'invoiceNumber': 'INV-${doc.id.substring(0, 8).toUpperCase()}',
        'customerName': saleData['customerName'] ?? 'Walk-in Customer',
        'customerPhone': saleData['customerPhone'] ?? 'N/A',
        'date': saleData['createdAt'] != null
            ? (saleData['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        'items': saleData['items'] ?? [],
        'subtotal': saleData['subtotal']?.toDouble() ?? 0.0,
        'tax': saleData['tax']?.toDouble() ?? 0.0,
        'discount': saleData['discount']?.toDouble() ?? 0.0,
        'total': saleData['total']?.toDouble() ?? 0.0,
        'status': 'PAID',
        'paymentMethod': saleData['paymentMethod'] ?? 'Cash',
      };
    } catch (e) {
      rethrow;
    }
  }

  // Generate invoice text for printing/sharing
  String generateInvoiceText(Map<String, dynamic> invoice) {
    StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('========================================');
    buffer.writeln('           SEARCH-A-HOLIC');
    buffer.writeln('         Inventory Management');
    buffer.writeln('========================================');
    buffer.writeln();

    // Invoice details
    buffer.writeln('Invoice #: ${invoice['invoiceNumber']}');
    buffer.writeln(
        'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(invoice['date'])}');
    buffer.writeln('Customer: ${invoice['customerName']}');
    if (invoice['customerPhone'] != 'N/A') {
      buffer.writeln('Phone: ${invoice['customerPhone']}');
    }
    buffer.writeln('Status: ${invoice['status']}');
    buffer.writeln();

    // Items
    buffer.writeln('ITEMS:');
    buffer.writeln('----------------------------------------');

    List<dynamic> items = invoice['items'] as List<dynamic>;
    for (var item in items) {
      String name = item['name']?.toString() ?? 'Unknown Item';
      int quantity = item['quantity']?.toInt() ?? 0;
      double price = item['price']?.toDouble() ?? 0.0;
      double total = quantity * price;

      buffer.writeln('${name}');
      buffer.writeln(
          '  ${quantity} x \$${price.toStringAsFixed(2)} = \$${total.toStringAsFixed(2)}');
      buffer.writeln();
    }

    buffer.writeln('----------------------------------------');

    // Totals
    buffer.writeln('Subtotal: \$${invoice['subtotal'].toStringAsFixed(2)}');

    if (invoice['discount'] > 0) {
      buffer.writeln('Discount: -\$${invoice['discount'].toStringAsFixed(2)}');
    }

    if (invoice['tax'] > 0) {
      buffer.writeln('Tax: \$${invoice['tax'].toStringAsFixed(2)}');
    }

    buffer.writeln('========================================');
    buffer.writeln('TOTAL: \$${invoice['total'].toStringAsFixed(2)}');
    buffer.writeln('========================================');
    buffer.writeln();
    buffer.writeln('Payment Method: ${invoice['paymentMethod']}');
    buffer.writeln();
    buffer.writeln('Thank you for your business!');
    buffer.writeln(
        'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}');

    return buffer.toString();
  }

  // Generate shareable invoice text with better formatting
  String generateShareableInvoiceText(Map<String, dynamic> invoice) {
    final StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('        🏪 SEARCH-A-HOLIC        ');
    buffer.writeln('     Digital Inventory System     ');
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln();

    // Invoice details
    buffer.writeln('📋 INVOICE DETAILS');
    buffer.writeln('Invoice No: ${invoice['invoiceNumber']}');
    buffer.writeln(
        'Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(invoice['date'])}');
    buffer.writeln('Status: ${invoice['status']}');
    buffer.writeln();

    // Customer details
    buffer.writeln('👤 CUSTOMER INFORMATION');
    buffer.writeln('Name: ${invoice['customerName']}');
    if (invoice['customerPhone'] != 'N/A') {
      buffer.writeln('Phone: ${invoice['customerPhone']}');
    }
    buffer.writeln();

    // Items
    buffer.writeln('🛒 ITEMS PURCHASED');
    buffer.writeln('─────────────────────────────────');

    List<dynamic> items = invoice['items'] ?? [];
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      buffer.writeln('${i + 1}. ${item['name']}');
      buffer.writeln(
          '   Qty: ${item['quantity']} × \$${item['price'].toStringAsFixed(2)} = \$${(item['quantity'] * item['price']).toStringAsFixed(2)}');
      if (i < items.length - 1) buffer.writeln();
    }

    buffer.writeln('─────────────────────────────────');

    // Totals
    buffer.writeln('💰 PAYMENT SUMMARY');
    buffer.writeln('Subtotal: \$${invoice['subtotal'].toStringAsFixed(2)}');
    if (invoice['discount'] > 0) {
      buffer.writeln('Discount: -\$${invoice['discount'].toStringAsFixed(2)}');
    }
    if (invoice['tax'] > 0) {
      buffer.writeln('Tax: \$${invoice['tax'].toStringAsFixed(2)}');
    }
    buffer.writeln('──────────────────');
    buffer.writeln('TOTAL: \$${invoice['total'].toStringAsFixed(2)}');
    buffer.writeln('Payment: ${invoice['paymentMethod']}');
    buffer.writeln();

    // Footer
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('      Thank you for your business!    ');
    buffer.writeln('   Generated by Search-A-Holic App   ');
    buffer.writeln('═══════════════════════════════════');

    return buffer.toString();
  }

  // Generate email-friendly invoice text
  String generateEmailInvoiceText(Map<String, dynamic> invoice) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('INVOICE - ${invoice['invoiceNumber']}');
    buffer.writeln('Search-A-Holic Digital Inventory System');
    buffer.writeln('');
    buffer.writeln(
        'Date: ${DateFormat('MMMM dd, yyyy').format(invoice['date'])}');
    buffer.writeln('Customer: ${invoice['customerName']}');
    if (invoice['customerPhone'] != 'N/A') {
      buffer.writeln('Phone: ${invoice['customerPhone']}');
    }
    buffer.writeln('');
    buffer.writeln('ITEMS:');

    List<dynamic> items = invoice['items'] ?? [];
    for (var item in items) {
      buffer.writeln(
          '• ${item['name']} - Qty: ${item['quantity']} × \$${item['price'].toStringAsFixed(2)} = \$${(item['quantity'] * item['price']).toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln('Subtotal: \$${invoice['subtotal'].toStringAsFixed(2)}');
    if (invoice['discount'] > 0) {
      buffer.writeln('Discount: -\$${invoice['discount'].toStringAsFixed(2)}');
    }
    if (invoice['tax'] > 0) {
      buffer.writeln('Tax: \$${invoice['tax'].toStringAsFixed(2)}');
    }
    buffer.writeln('TOTAL: \$${invoice['total'].toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Thank you for your business!');

    return buffer.toString();
  }

  // Get latest invoice for display
  Future<Map<String, dynamic>?> getLatestInvoice() async {
    try {
      List<Map<String, dynamic>> invoices = await getRecentInvoices(limit: 1);
      return invoices.isNotEmpty ? invoices.first : null;
    } catch (e) {
      rethrow;
    }
  }

  // Generate printable invoice text (monospace formatting)
  String generatePrintableInvoiceText(Map<String, dynamic> invoice) {
    final StringBuffer buffer = StringBuffer();

    // Header with fixed width
    buffer.writeln('================================================');
    buffer.writeln('              SEARCH-A-HOLIC                   ');
    buffer.writeln('         Digital Inventory System              ');
    buffer.writeln('================================================');
    buffer.writeln();

    // Invoice details
    buffer.writeln('Invoice No: ${invoice['invoiceNumber']}');
    buffer.writeln(
        'Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(invoice['date'])}');
    buffer.writeln('Status: ${invoice['status']}');
    buffer.writeln();

    // Customer details
    buffer.writeln('Customer: ${invoice['customerName']}');
    if (invoice['customerPhone'] != 'N/A') {
      buffer.writeln('Phone: ${invoice['customerPhone']}');
    }
    buffer.writeln();

    // Items header
    buffer.writeln('ITEMS:');
    buffer.writeln('------------------------------------------------');
    buffer.writeln('Item                    Qty    Price     Total');
    buffer.writeln('------------------------------------------------');

    List<dynamic> items = invoice['items'] ?? [];
    for (var item in items) {
      String name = item['name'].toString();
      if (name.length > 20) {
        name = name.substring(0, 17) + '...';
      } else {
        name = name.padRight(20);
      }

      String qty = item['quantity'].toString().padLeft(6);
      String price = '\$${item['price'].toStringAsFixed(2)}'.padLeft(9);
      String total =
          '\$${(item['quantity'] * item['price']).toStringAsFixed(2)}'
              .padLeft(9);

      buffer.writeln('$name $qty $price $total');
    }

    buffer.writeln('------------------------------------------------');

    // Totals
    String subtotal = '\$${invoice['subtotal'].toStringAsFixed(2)}'.padLeft(15);
    buffer.writeln('Subtotal:${subtotal}');

    if (invoice['discount'] > 0) {
      String discount =
          '-\$${invoice['discount'].toStringAsFixed(2)}'.padLeft(14);
      buffer.writeln('Discount:${discount}');
    }

    if (invoice['tax'] > 0) {
      String tax = '\$${invoice['tax'].toStringAsFixed(2)}'.padLeft(15);
      buffer.writeln('Tax:${tax}');
    }

    buffer.writeln('------------------------------------------------');
    String finalTotal = '\$${invoice['total'].toStringAsFixed(2)}'.padLeft(15);
    buffer.writeln('TOTAL:${finalTotal}');
    buffer.writeln();

    // Payment info
    buffer.writeln('Payment: ${invoice['paymentMethod']}');
    buffer.writeln();

    // Footer
    buffer.writeln('================================================');
    buffer.writeln('         Thank you for your business!          ');
    buffer.writeln('      Generated by Search-A-Holic App         ');
    buffer.writeln('================================================');

    return buffer.toString();
  }
}
