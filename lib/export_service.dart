import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:desktop_search_a_holic/firebase_service.dart';
import 'package:desktop_search_a_holic/sales_service.dart';
import 'package:desktop_search_a_holic/backup_history_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportService {
  final FirebaseService _firebaseService = FirebaseService();
  final SalesService _salesService = SalesService();
  final BackupHistoryService _backupHistoryService = BackupHistoryService();

  // Static instance for convenience
  static final ExportService _instance = ExportService();
  static ExportService get instance => _instance;

  // Static methods for convenience
  static Future<bool> createBackup() async {
    try {
      await _instance.createDataBackup();
      await _instance._backupHistoryService.logBackupOperation(
        type: 'manual',
        status: 'success',
        description: 'Manual backup created successfully',
      );
      return true;
    } catch (e) {
      await _instance._backupHistoryService.logBackupOperation(
        type: 'manual',
        status: 'failed',
        description: 'Manual backup failed: $e',
      );
      return false;
    }
  }

  static Future<bool> exportAllData() async {
    try {
      await _instance.exportProductsToCSV();
      await _instance.exportSalesToCSV();
      await _instance.exportBusinessReportToCSV();
      await _instance._backupHistoryService.logBackupOperation(
        type: 'export',
        status: 'success',
        description: 'Data exported successfully (CSV format)',
      );
      return true;
    } catch (e) {
      await _instance._backupHistoryService.logBackupOperation(
        type: 'export',
        status: 'failed',
        description: 'Data export failed: $e',
      );
      throw Exception('Failed to export data: $e');
    }
  }

  /// Save a formatted report to file
  Future<String> saveFormattedReportInstance(
      String content, String fileName) async {
    try {
      Directory? targetDir;

      // Get platform-specific downloads directory
      if (Platform.isWindows) {
        targetDir =
            Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      } else if (Platform.isLinux) {
        targetDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else if (Platform.isMacOS) {
        targetDir = Directory('${Platform.environment['HOME']}/Downloads');
      } else {
        targetDir = await getApplicationDocumentsDirectory();
      }

      if (!targetDir.existsSync()) {
        targetDir = await getApplicationDocumentsDirectory();
      }

      // Create unique filename with timestamp
      String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String finalFileName = '${fileName}_$timestamp.txt';
      File file = File('${targetDir.path}/$finalFileName');

      // Write content to file
      await file.writeAsString(content);

      // Log the operation
      await _backupHistoryService.logBackupOperation(
        type: 'report',
        status: 'success',
        description: 'Formatted report saved: $finalFileName',
      );

      return file.path;
    } catch (e) {
      await _backupHistoryService.logBackupOperation(
        type: 'report',
        status: 'failed',
        description: 'Failed to save formatted report: $e',
      );
      throw Exception('Failed to save formatted report: $e');
    }
  }

  static Future<String> saveFormattedReport(
      String content, String fileName) async {
    return await _instance.saveFormattedReportInstance(content, fileName);
  }

  // Export products to CSV
  Future<String> exportProductsToCSV() async {
    try {
      List<Map<String, dynamic>> products =
          await _firebaseService.getProducts();

      String csvContent =
          'Product Name,Price,Quantity,Category,Expiry Date,Created At\n';

      for (var product in products) {
        csvContent += '"${product['name'] ?? ''}",'
            '"${product['price'] ?? ''}",'
            '"${product['quantity'] ?? ''}",'
            '"${product['category'] ?? ''}",'
            '"${product['expiry'] ?? ''}",'
            '"${product['createdAt'] ?? ''}"\n';
      }

      return await _saveFile(
          csvContent, 'products_export_${_getTimestamp()}.csv');
    } catch (e) {
      throw Exception('Failed to export products: $e');
    }
  }

  // Export sales to CSV
  Future<String> exportSalesToCSV() async {
    try {
      List<Map<String, dynamic>> sales = await _salesService.getSales();

      String csvContent =
          'Sale ID,Customer Name,Customer Phone,Date,Subtotal,Discount,Tax,Total,Items\n';

      for (var sale in sales) {
        String itemsDetails = '';
        if (sale['items'] != null) {
          List<dynamic> items = sale['items'];
          itemsDetails = items
              .map((item) =>
                  '${item['name']} (Qty: ${item['quantity']}, Price: \$${item['price']})')
              .join('; ');
        }

        csvContent += '"${sale['id'] ?? ''}",'
            '"${sale['customerName'] ?? ''}",'
            '"${sale['customerPhone'] ?? ''}",'
            '"${sale['date'] ?? ''}",'
            '"${sale['subtotal'] ?? ''}",'
            '"${sale['discount'] ?? ''}",'
            '"${sale['tax'] ?? ''}",'
            '"${sale['total'] ?? ''}",'
            '"$itemsDetails"\n';
      }

      return await _saveFile(csvContent, 'sales_export_${_getTimestamp()}.csv');
    } catch (e) {
      throw Exception('Failed to export sales: $e');
    }
  }

  // Export complete business report to CSV
  Future<String> exportBusinessReportToCSV() async {
    try {
      Map<String, dynamic> stats = await _salesService.getSalesStats();
      List<Map<String, dynamic>> products =
          await _firebaseService.getProducts();
      List<Map<String, dynamic>> sales = await _salesService.getSales();

      String csvContent =
          'Business Report - Generated on ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n\n';

      // Summary statistics
      csvContent += 'SUMMARY STATISTICS\n';
      csvContent += 'Metric,Value\n';
      csvContent +=
          'Total Sales Amount,\$${stats['totalSalesAmount']?.toStringAsFixed(2) ?? '0.00'}\n';
      csvContent += 'Total Orders,${stats['totalOrders'] ?? 0}\n';
      csvContent += 'Unique Customers,${stats['uniqueCustomers'] ?? 0}\n';
      csvContent +=
          'Top Selling Product,${stats['topSellingProduct'] ?? 'N/A'}\n';
      csvContent += 'Total Products,${products.length}\n';
      csvContent += '\n';

      // Low stock alerts
      csvContent += 'LOW STOCK ALERTS\n';
      csvContent += 'Product Name,Current Stock,Status\n';
      for (var product in products) {
        int stock = product['quantity'] ?? 0;
        if (stock <= 10) {
          String status = stock == 0 ? 'Out of Stock' : 'Low Stock';
          csvContent += '"${product['name'] ?? ''}",${stock},$status\n';
        }
      }
      csvContent += '\n';

      // Recent sales summary
      csvContent += 'RECENT SALES (Last 10)\n';
      csvContent += 'Date,Customer,Total,Items Count\n';
      var recentSales = sales.take(10);
      for (var sale in recentSales) {
        int itemCount = sale['items']?.length ?? 0;
        csvContent += '"${sale['date'] ?? ''}",'
            '"${sale['customerName'] ?? ''}",'
            '\$${sale['total']?.toStringAsFixed(2) ?? '0.00'},'
            '$itemCount\n';
      }

      return await _saveFile(
          csvContent, 'business_report_${_getTimestamp()}.csv');
    } catch (e) {
      throw Exception('Failed to generate business report: $e');
    }
  }

  // Create backup of all data in JSON format
  Future<String> createDataBackup() async {
    try {
      Map<String, dynamic> backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'products': await _firebaseService.getProducts(),
        'sales': await _salesService.getSales(),
        'statistics': await _salesService.getSalesStats(),
      };

      String jsonContent = JsonEncoder.withIndent('  ').convert(backupData);
      return await _saveFile(
          jsonContent, 'search_a_holic_backup_${_getTimestamp()}.json');
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Generate inventory report with stock levels
  Future<String> generateInventoryReport() async {
    try {
      List<Map<String, dynamic>> products =
          await _firebaseService.getProducts();

      String csvContent =
          'INVENTORY REPORT - ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}\n\n';
      csvContent +=
          'Product Name,Category,Current Stock,Status,Price,Expiry Date\n';

      for (var product in products) {
        int stock = product['quantity'] ?? 0;
        String status;
        if (stock == 0) {
          status = 'Out of Stock';
        } else if (stock <= 5) {
          status = 'Critical';
        } else if (stock <= 10) {
          status = 'Low Stock';
        } else {
          status = 'In Stock';
        }

        csvContent += '"${product['name'] ?? ''}",'
            '"${product['category'] ?? ''}",'
            '$stock,'
            '$status,'
            '\$${product['price'] ?? '0.00'},'
            '"${product['expiry'] ?? ''}"\n';
      }

      return await _saveFile(
          csvContent, 'inventory_report_${_getTimestamp()}.csv');
    } catch (e) {
      throw Exception('Failed to generate inventory report: $e');
    }
  }

  // Save file to documents directory
  Future<String> _saveFile(String content, String fileName) async {
    try {
      Directory? directory;

      if (kIsWeb) {
        throw UnsupportedError('File saving not supported on web platform');
      }

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getExternalStorageDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access documents directory');
      }

      // Create SearchAHolic folder if it doesn't exist
      Directory searchAHolicDir =
          Directory('${directory.path}/SearchAHolic/Exports');
      if (!await searchAHolicDir.exists()) {
        await searchAHolicDir.create(recursive: true);
      }

      File file = File('${searchAHolicDir.path}/$fileName');
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  // Get timestamp for file naming
  String _getTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  // Show export success dialog
  static void showExportSuccess(
      BuildContext context, String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File has been exported successfully!'),
            SizedBox(height: 12),
            Text('File Name:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(fileName),
            SizedBox(height: 8),
            Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(filePath, style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show export error dialog
  static void showExportError(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Export Failed'),
          ],
        ),
        content: Text('Failed to export data: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
