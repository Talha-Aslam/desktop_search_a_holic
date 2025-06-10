import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PdfService {
  static const String _appName = 'Search-A-Holic';

  /// Generate a formatted invoice text that can be used for PDF creation
  static String generateInvoiceText(Map<String, dynamic> invoice) {
    final StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 60);
    buffer.writeln('                    INVOICE');
    buffer.writeln('                 $_appName');
    buffer.writeln('=' * 60);
    buffer.writeln();

    // Invoice details
    buffer.writeln('Invoice ID: ${invoice['id'] ?? 'N/A'}');
    buffer.writeln(
        'Date: ${invoice['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    buffer.writeln('Status: ${invoice['status'] ?? 'Completed'}');
    buffer.writeln();

    // Customer details
    buffer.writeln('BILL TO:');
    buffer.writeln('-' * 20);
    buffer
        .writeln('Customer: ${invoice['customerName'] ?? 'Walk-in Customer'}');
    if (invoice['customerPhone'] != null &&
        invoice['customerPhone'].toString().isNotEmpty) {
      buffer.writeln('Phone: ${invoice['customerPhone']}');
    }
    buffer.writeln();

    // Items table
    buffer.writeln('ITEMS:');
    buffer.writeln('-' * 60);
    buffer.writeln('Item                    Qty    Price     Total');
    buffer.writeln('-' * 60);

    if (invoice['items'] != null) {
      for (var item in invoice['items']) {
        String name = (item['name'] ?? 'Unknown').toString();
        if (name.length > 20) name = name.substring(0, 17) + '...';

        int qty = item['quantity'] ?? 0;
        double price = (item['price'] ?? 0.0).toDouble();
        double total = price * qty;

        buffer.writeln('${name.padRight(20)} ${qty.toString().padLeft(6)} '
            '\$${price.toStringAsFixed(2).padLeft(8)} '
            '\$${total.toStringAsFixed(2).padLeft(8)}');
      }
    }

    buffer.writeln('-' * 60);

    // Totals
    double subtotal = (invoice['subtotal'] ?? 0.0).toDouble();
    double tax = (invoice['tax'] ?? 0.0).toDouble();
    double discount = (invoice['discount'] ?? 0.0).toDouble();
    double total = (invoice['total'] ?? 0.0).toDouble();

    buffer
        .writeln('Subtotal:${'\$${subtotal.toStringAsFixed(2)}'.padLeft(48)}');
    if (discount > 0) {
      buffer.writeln(
          'Discount:${'-\$${discount.toStringAsFixed(2)}'.padLeft(48)}');
    }
    buffer.writeln('Tax (10%):${'\$${tax.toStringAsFixed(2)}'.padLeft(47)}');
    buffer.writeln('=' * 60);
    buffer.writeln('TOTAL:${'\$${total.toStringAsFixed(2)}'.padLeft(51)}');
    buffer.writeln('=' * 60);
    buffer.writeln();

    // Footer
    buffer.writeln('Thank you for your business!');
    buffer.writeln(
        'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln();

    return buffer.toString();
  }

  /// Generate a formatted sales report text
  static String generateSalesReportText(Map<String, dynamic> reportData) {
    final StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 70);
    buffer.writeln('                        SALES REPORT');
    buffer.writeln('                       $_appName');
    buffer.writeln('=' * 70);
    buffer.writeln();

    // Report period
    String period = reportData['period'] ?? 'All Time';
    buffer.writeln('Report Period: $period');
    buffer.writeln(
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln();

    // Summary statistics
    buffer.writeln('SUMMARY:');
    buffer.writeln('-' * 30);
    buffer.writeln(
        'Total Sales: \$${(reportData['totalSales'] ?? 0.0).toStringAsFixed(2)}');
    buffer.writeln('Total Orders: ${reportData['totalOrders'] ?? 0}');
    buffer.writeln(
        'Average Order Value: \$${(reportData['averageOrderValue'] ?? 0.0).toStringAsFixed(2)}');
    buffer.writeln();

    // Sales breakdown
    if (reportData['salesByCategory'] != null) {
      buffer.writeln('SALES BY CATEGORY:');
      buffer.writeln('-' * 40);
      Map<String, dynamic> salesByCategory = reportData['salesByCategory'];
      salesByCategory.forEach((category, amount) {
        buffer.writeln(
            '${category.padRight(25)} \$${amount.toStringAsFixed(2).padLeft(10)}');
      });
      buffer.writeln();
    }

    // Top products
    if (reportData['topProducts'] != null) {
      buffer.writeln('TOP SELLING PRODUCTS:');
      buffer.writeln('-' * 50);
      buffer.writeln('Product                      Qty Sold    Revenue');
      buffer.writeln('-' * 50);

      List<dynamic> topProducts = reportData['topProducts'];
      for (var product in topProducts.take(10)) {
        String name = (product['name'] ?? 'Unknown').toString();
        if (name.length > 25) name = name.substring(0, 22) + '...';

        int qtySold = product['quantitySold'] ?? 0;
        double revenue = (product['revenue'] ?? 0.0).toDouble();

        buffer.writeln('${name.padRight(25)} ${qtySold.toString().padLeft(8)} '
            '\$${revenue.toStringAsFixed(2).padLeft(10)}');
      }
      buffer.writeln();
    }

    // Monthly breakdown
    if (reportData['monthlyData'] != null) {
      buffer.writeln('MONTHLY BREAKDOWN:');
      buffer.writeln('-' * 30);
      Map<String, dynamic> monthlyData = reportData['monthlyData'];
      monthlyData.forEach((month, data) {
        buffer.writeln(
            '$month: \$${data['sales'].toStringAsFixed(2)} (${data['orders']} orders)');
      });
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generate inventory report text
  static String generateInventoryReportText(
      List<Map<String, dynamic>> products) {
    final StringBuffer buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 80);
    buffer.writeln('                            INVENTORY REPORT');
    buffer.writeln('                           $_appName');
    buffer.writeln('=' * 80);
    buffer.writeln();

    buffer.writeln(
        'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('Total Products: ${products.length}');
    buffer.writeln();

    // Calculate totals
    double totalValue = 0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (var product in products) {
      int qty = product['quantity'] ?? 0;
      double price = (product['price'] ?? 0.0).toDouble();
      totalValue += qty * price;

      if (qty == 0)
        outOfStockCount++;
      else if (qty < 10) lowStockCount++;
    }

    buffer.writeln('SUMMARY:');
    buffer.writeln('-' * 40);
    buffer.writeln('Total Inventory Value: \$${totalValue.toStringAsFixed(2)}');
    buffer.writeln('Out of Stock Items: $outOfStockCount');
    buffer.writeln('Low Stock Items (< 10): $lowStockCount');
    buffer.writeln();

    // Product list
    buffer.writeln('PRODUCT INVENTORY:');
    buffer.writeln('-' * 80);
    buffer.writeln(
        'Product Name                  Category        Qty    Price     Value');
    buffer.writeln('-' * 80);

    for (var product in products) {
      String name = (product['name'] ?? 'Unknown').toString();
      if (name.length > 25) name = name.substring(0, 22) + '...';

      String category = (product['category'] ?? 'Other').toString();
      if (category.length > 12) category = category.substring(0, 9) + '...';

      int qty = product['quantity'] ?? 0;
      double price = (product['price'] ?? 0.0).toDouble();
      double value = qty * price;

      // Add warning indicators
      String qtyStr = qty.toString();
      if (qty == 0)
        qtyStr += ' (OUT)';
      else if (qty < 10) qtyStr += ' (LOW)';

      buffer.writeln('${name.padRight(25)} ${category.padRight(12)} '
          '${qtyStr.padLeft(8)} \$${price.toStringAsFixed(2).padLeft(8)} '
          '\$${value.toStringAsFixed(2).padLeft(8)}');
    }

    buffer.writeln('-' * 80);
    buffer
        .writeln('Total Value: \$${totalValue.toStringAsFixed(2)}'.padLeft(75));
    buffer.writeln();

    return buffer.toString();
  }

  /// Save text content to a file in the downloads directory
  static Future<String> saveTextToFile(String content, String fileName) async {
    try {
      Directory? downloadsDir;

      if (Platform.isWindows) {
        downloadsDir =
            Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      } else if (Platform.isLinux) {
        downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else if (Platform.isMacOS) {
        downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else {
        // Fallback to documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (!downloadsDir.existsSync()) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      // Ensure unique filename
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String finalFileName = '${fileName}_$timestamp.txt';

      File file = File('${downloadsDir.path}/$finalFileName');
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  /// Create a simple HTML version of the invoice for better formatting
  static String generateInvoiceHTML(Map<String, dynamic> invoice) {
    final StringBuffer html = StringBuffer();

    html.write('''
<!DOCTYPE html>
<html>
<head>
    <title>Invoice - ${invoice['id'] ?? 'N/A'}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; }
        .company-name { font-size: 24px; font-weight: bold; }
        .invoice-title { font-size: 20px; margin: 10px 0; }
        .invoice-details { margin: 20px 0; }
        .customer-details { margin: 20px 0; }
        .items-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .items-table th, .items-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .items-table th { background-color: #f2f2f2; }
        .totals { margin: 20px 0; text-align: right; }
        .total-line { margin: 5px 0; }
        .grand-total { font-weight: bold; font-size: 18px; border-top: 2px solid #333; padding-top: 10px; }
        .footer { text-align: center; margin-top: 40px; font-style: italic; }
    </style>
</head>
<body>
    <div class="header">
        <div class="company-name">$_appName</div>
        <div class="invoice-title">INVOICE</div>
    </div>
    
    <div class="invoice-details">
        <strong>Invoice ID:</strong> ${invoice['id'] ?? 'N/A'}<br>
        <strong>Date:</strong> ${invoice['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}<br>
        <strong>Status:</strong> ${invoice['status'] ?? 'Completed'}
    </div>
    
    <div class="customer-details">
        <strong>Bill To:</strong><br>
        ${invoice['customerName'] ?? 'Walk-in Customer'}<br>
''');

    if (invoice['customerPhone'] != null &&
        invoice['customerPhone'].toString().isNotEmpty) {
      html.write('        Phone: ${invoice['customerPhone']}<br>');
    }

    html.write('''
    </div>
    
    <table class="items-table">
        <thead>
            <tr>
                <th>Item</th>
                <th>Quantity</th>
                <th>Unit Price</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
''');

    if (invoice['items'] != null) {
      for (var item in invoice['items']) {
        int qty = item['quantity'] ?? 0;
        double price = (item['price'] ?? 0.0).toDouble();
        double total = price * qty;

        html.write('''
            <tr>
                <td>${item['name'] ?? 'Unknown'}</td>
                <td>$qty</td>
                <td>\$${price.toStringAsFixed(2)}</td>
                <td>\$${total.toStringAsFixed(2)}</td>
            </tr>
''');
      }
    }

    html.write('''
        </tbody>
    </table>
    
    <div class="totals">
''');

    double subtotal = (invoice['subtotal'] ?? 0.0).toDouble();
    double tax = (invoice['tax'] ?? 0.0).toDouble();
    double discount = (invoice['discount'] ?? 0.0).toDouble();
    double total = (invoice['total'] ?? 0.0).toDouble();

    html.write(
        '        <div class="total-line">Subtotal: \$${subtotal.toStringAsFixed(2)}</div>');

    if (discount > 0) {
      html.write(
          '        <div class="total-line">Discount: -\$${discount.toStringAsFixed(2)}</div>');
    }

    html.write('''
        <div class="total-line">Tax (10%): \$${tax.toStringAsFixed(2)}</div>
        <div class="grand-total">Total: \$${total.toStringAsFixed(2)}</div>
    </div>
    
    <div class="footer">
        Thank you for your business!<br>
        Generated on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
    </div>
</body>
</html>
''');

    return html.toString();
  }

  /// Save HTML content to file
  static Future<String> saveHTMLToFile(
      String htmlContent, String fileName) async {
    try {
      Directory? downloadsDir;

      if (Platform.isWindows) {
        downloadsDir =
            Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      } else if (Platform.isLinux) {
        downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else if (Platform.isMacOS) {
        downloadsDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (!downloadsDir.existsSync()) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String finalFileName = '${fileName}_$timestamp.html';

      File file = File('${downloadsDir.path}/$finalFileName');
      await file.writeAsString(htmlContent);

      return file.path;
    } catch (e) {
      throw Exception('Failed to save HTML file: $e');
    }
  }
}
