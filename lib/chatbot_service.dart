import 'package:flutter/material.dart';
import 'package:desktop_search_a_holic/firebase_service.dart';
import 'package:desktop_search_a_holic/sales_service.dart';
import 'package:desktop_search_a_holic/stock_alert_service.dart';
import 'package:desktop_search_a_holic/reports_service.dart';
import 'dart:math';

enum ChatResponseType {
  text,
  data,
  chart,
  action,
  error,
}

class ChatResponse {
  final String text;
  final ChatResponseType type;
  final Map<String, dynamic>? data;
  final List<Map<String, dynamic>>? suggestions;
  final VoidCallback? action;

  ChatResponse({
    required this.text,
    this.type = ChatResponseType.text,
    this.data,
    this.suggestions,
    this.action,
  });
}

class ChatBotService {
  final FirebaseService _firebaseService = FirebaseService();
  final SalesService _salesService = SalesService();
  final ReportsService _reportsService = ReportsService();
  final StockAlertService _stockAlertService = StockAlertService();

  // Advanced NLP Keywords and Patterns
  static const Map<String, List<String>> _intentKeywords = {
    'sales_query': ['sales', 'revenue', 'income', 'earnings', 'money', 'profit'],
    'product_query': ['product', 'inventory', 'stock', 'item', 'medicine'],
    'customer_query': ['customer', 'client', 'buyer', 'purchase'],
    'alert_query': ['alert', 'warning', 'notification', 'low stock', 'out of stock'],
    'report_query': ['report', 'analytics', 'stats', 'statistics', 'summary'],
    'action_add': ['add', 'create', 'new', 'insert'],
    'action_edit': ['edit', 'update', 'modify', 'change'],
    'action_delete': ['delete', 'remove', 'drop'],
    'action_search': ['find', 'search', 'look for', 'show me'],
    'time_today': ['today', 'now', 'current'],
    'time_week': ['week', 'weekly', 'this week'],
    'time_month': ['month', 'monthly', 'this month'],
    'help_query': ['help', 'how', 'what', 'guide', 'tutorial'],
  };

  // Business Intelligence Queries
  Future<ChatResponse> processMessage(String message) async {
    try {
      final String cleanMessage = message.toLowerCase().trim();
      
      // Analyze intent
      List<String> detectedIntents = _analyzeIntent(cleanMessage);
      Map<String, dynamic> entities = _extractEntities(cleanMessage);
      
      // Handle complex business queries
      if (detectedIntents.contains('sales_query')) {
        return await _handleSalesQuery(cleanMessage, entities);
      } else if (detectedIntents.contains('product_query')) {
        return await _handleProductQuery(cleanMessage, entities);
      } else if (detectedIntents.contains('alert_query')) {
        return await _handleAlertQuery(cleanMessage, entities);
      } else if (detectedIntents.contains('report_query')) {
        return await _handleReportQuery(cleanMessage, entities);
      } else if (detectedIntents.contains('customer_query')) {
        return await _handleCustomerQuery(cleanMessage, entities);
      } else if (detectedIntents.any((intent) => intent.startsWith('action_'))) {
        return await _handleActionQuery(cleanMessage, detectedIntents, entities);
      } else if (detectedIntents.contains('help_query')) {
        return _handleHelpQuery(cleanMessage);
      }

      // Enhanced general conversation
      return _handleGeneralQuery(cleanMessage);
    } catch (e) {
      return ChatResponse(
        text: "I encountered an error while processing your request: ${e.toString()}",
        type: ChatResponseType.error,
      );
    }
  }

  // Intent Analysis using keyword matching and patterns
  List<String> _analyzeIntent(String message) {
    List<String> intents = [];
    
    _intentKeywords.forEach((intent, keywords) {
      for (String keyword in keywords) {
        if (message.contains(keyword)) {
          intents.add(intent);
          break;
        }
      }
    });
    
    return intents;
  }

  // Entity Extraction (numbers, dates, product names, etc.)
  Map<String, dynamic> _extractEntities(String message) {
    Map<String, dynamic> entities = {};
    
    // Extract numbers
    RegExp numberRegex = RegExp(r'\b\d+\.?\d*\b');
    Iterable<Match> numberMatches = numberRegex.allMatches(message);
    List<double> numbers = numberMatches.map((match) => 
        double.tryParse(match.group(0)!) ?? 0).toList();
    if (numbers.isNotEmpty) entities['numbers'] = numbers;
    
    // Extract time references
    if (message.contains('today')) entities['timeframe'] = 'today';
    if (message.contains('week')) entities['timeframe'] = 'week';
    if (message.contains('month')) entities['timeframe'] = 'month';
    if (message.contains('year')) entities['timeframe'] = 'year';
    
    return entities;
  }

  // Handle Sales-related queries
  Future<ChatResponse> _handleSalesQuery(String message, Map<String, dynamic> entities) async {
    try {
      if (message.contains('today')) {
        List<Map<String, dynamic>> todaySales = await _salesService.getTodaySales();
        double todayRevenue = todaySales.fold(0.0, (sum, sale) => 
            sum + ((sale['total'] as num?)?.toDouble() ?? 0.0));
        
        return ChatResponse(
          text: "📊 **Today's Sales Performance**\n\n"
                "• **Orders**: ${todaySales.length}\n"
                "• **Revenue**: \$${todayRevenue.toStringAsFixed(2)}\n"
                "• **Avg Order**: \$${todaySales.isNotEmpty ? (todayRevenue / todaySales.length).toStringAsFixed(2) : '0.00'}",
          type: ChatResponseType.data,
          data: {
            'orders': todaySales.length,
            'revenue': todayRevenue,
            'sales': todaySales,
          },
          suggestions: [
            {'text': 'Show sales details', 'action': 'show_sales_details'},
            {'text': 'Compare with yesterday', 'action': 'compare_sales'},
            {'text': 'Top selling products today', 'action': 'top_products_today'},
          ],
        );
      } else if (message.contains('total') || message.contains('overall')) {
        Map<String, dynamic> stats = await _salesService.getSalesStats();
        
        return ChatResponse(
          text: "💰 **Overall Sales Statistics**\n\n"
                "• **Total Revenue**: \$${stats['totalSalesAmount']?.toStringAsFixed(2) ?? '0.00'}\n"
                "• **Total Orders**: ${stats['totalOrders'] ?? 0}\n"
                "• **Unique Customers**: ${stats['uniqueCustomers'] ?? 0}\n"
                "• **Top Product**: ${stats['topSellingProduct'] ?? 'N/A'} (${stats['topSellingCount'] ?? 0} sold)",
          type: ChatResponseType.data,
          data: stats,
          suggestions: [
            {'text': 'Generate sales report', 'action': 'generate_sales_report'},
            {'text': 'View monthly trends', 'action': 'monthly_trends'},
            {'text': 'Customer insights', 'action': 'customer_insights'},
          ],
        );
      }
      
      return ChatResponse(
        text: "I can help you with sales data! Try asking about:\n• Today's sales\n• Total revenue\n• Top selling products\n• Customer statistics",
        suggestions: [
          {'text': "Show today's sales", 'action': 'today_sales'},
          {'text': 'Total revenue and orders', 'action': 'total_stats'},
          {'text': 'Best performing products', 'action': 'top_products'},
        ],
      );
    } catch (e) {
      return ChatResponse(
        text: "I couldn't retrieve sales data at the moment. Please check your connection and try again.",
        type: ChatResponseType.error,
      );
    }
  }

  // Handle Product/Inventory queries
  Future<ChatResponse> _handleProductQuery(String message, Map<String, dynamic> entities) async {
    try {
      if (message.contains('low stock') || message.contains('running low')) {
        // Get stock alerts
        List<StockAlert> alerts = _stockAlertService.activeAlerts;
        int lowStockCount = alerts.where((alert) => 
            alert.severity == AlertSeverity.warning).length;
        int criticalCount = alerts.where((alert) => 
            alert.severity == AlertSeverity.critical).length;
        int outOfStockCount = alerts.where((alert) => 
            alert.severity == AlertSeverity.danger).length;
        
        return ChatResponse(
          text: "⚠️ **Stock Alert Summary**\n\n"
                "• **Critical Stock**: $criticalCount items\n"
                "• **Low Stock**: $lowStockCount items\n"
                "• **Out of Stock**: $outOfStockCount items\n\n"
                "${alerts.isNotEmpty ? 'Immediate attention needed for ${alerts.length} products!' : 'All products are well-stocked! 🎉'}",
          type: ChatResponseType.data,
          data: {
            'alerts': alerts.map((alert) => {
              'name': alert.productName,
              'stock': alert.currentStock,
              'severity': alert.severity.toString(),
            }).toList(),
          },
          suggestions: [
            {'text': 'Show detailed alerts', 'action': 'detailed_alerts'},
            {'text': 'View stock alerts page', 'action': 'navigate_alerts'},
            {'text': 'Products to reorder', 'action': 'reorder_list'},
          ],
        );
      } else if (message.contains('total') || message.contains('count')) {
        List<Map<String, dynamic>> products = await _firebaseService.getProducts();
        
        // Calculate inventory insights
        int totalProducts = products.length;
        double totalValue = products.fold(0.0, (sum, product) => 
            sum + ((product['price'] as num?)?.toDouble() ?? 0) * 
                  ((product['quantity'] as num?)?.toDouble() ?? 0));
        
        Map<String, int> categoryCount = {};
        for (var product in products) {
          String category = product['category'] ?? 'Other';
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
        
        String topCategory = '';
        int maxCount = 0;
        categoryCount.forEach((category, count) {
          if (count > maxCount) {
            topCategory = category;
            maxCount = count;
          }
        });
        
        return ChatResponse(
          text: "📦 **Inventory Overview**\n\n"
                "• **Total Products**: $totalProducts\n"
                "• **Total Value**: \$${totalValue.toStringAsFixed(2)}\n"
                "• **Categories**: ${categoryCount.length}\n"
                "• **Top Category**: $topCategory ($maxCount items)",
          type: ChatResponseType.data,
          data: {
            'total': totalProducts,
            'value': totalValue,
            'categories': categoryCount,
            'products': products,
          },
          suggestions: [
            {'text': 'Show all products', 'action': 'show_products'},
            {'text': 'Category breakdown', 'action': 'category_analysis'},
            {'text': 'Low stock items', 'action': 'low_stock_items'},
          ],
        );
      } else if (message.contains('search') || message.contains('find')) {
        // Extract potential product name
        List<String> words = message.split(' ');
        String searchTerm = '';
        for (int i = 0; i < words.length; i++) {
          if (words[i] == 'find' || words[i] == 'search') {
            if (i + 1 < words.length) {
              searchTerm = words.sublist(i + 1).join(' ');
              break;
            }
          }
        }
        
        if (searchTerm.isNotEmpty) {
          List<Map<String, dynamic>> products = await _firebaseService.getProducts();
          List<Map<String, dynamic>> matches = products.where((product) =>
              product['name']?.toString().toLowerCase().contains(searchTerm) ?? false).toList();
          
          if (matches.isNotEmpty) {
            String resultsText = matches.take(5).map((product) =>
                "• **${product['name']}** - Qty: ${product['quantity']}, Price: \$${product['price']}").join('\n');
            
            return ChatResponse(
              text: "🔍 **Search Results for \"$searchTerm\"**\n\n$resultsText${matches.length > 5 ? '\n\n...and ${matches.length - 5} more results' : ''}",
              type: ChatResponseType.data,
              data: {'results': matches, 'searchTerm': searchTerm},
              suggestions: [
                {'text': 'Show all results', 'action': 'show_all_search'},
                {'text': 'Add new product', 'action': 'add_product'},
                {'text': 'Edit first result', 'action': 'edit_first_result'},
              ],
            );
          } else {
            return ChatResponse(
              text: "No products found matching \"$searchTerm\". Would you like to add a new product?",
              suggestions: [
                {'text': 'Add new product', 'action': 'add_product'},
                {'text': 'View all products', 'action': 'show_products'},
                {'text': 'Search tips', 'action': 'search_help'},
              ],
            );
          }
        }
      }
      
      return ChatResponse(
        text: "I can help you with inventory management! Try asking:\n• How many products do I have?\n• Show low stock items\n• Find a specific product\n• What's my inventory value?",
        suggestions: [
          {'text': 'Total inventory count', 'action': 'inventory_count'},
          {'text': 'Low stock alerts', 'action': 'low_stock'},
          {'text': 'Search products', 'action': 'search_products'},
        ],
      );
    } catch (e) {
      return ChatResponse(
        text: "I couldn't access inventory data right now. Please try again later.",
        type: ChatResponseType.error,
      );
    }
  }

  // Handle Stock Alert queries
  Future<ChatResponse> _handleAlertQuery(String message, Map<String, dynamic> entities) async {
    try {
      List<StockAlert> alerts = _stockAlertService.activeAlerts;
      
      if (alerts.isEmpty) {
        return ChatResponse(
          text: "🎉 **Great news!** No stock alerts at the moment.\n\nAll your products are well-stocked and ready for business!",
          suggestions: [
            {'text': 'View all products', 'action': 'show_products'},
            {'text': 'Add new product', 'action': 'add_product'},
            {'text': 'Sales dashboard', 'action': 'dashboard'},
          ],
        );
      }
      
      // Group alerts by severity
      List<StockAlert> critical = alerts.where((a) => a.severity == AlertSeverity.critical).toList();
      List<StockAlert> warning = alerts.where((a) => a.severity == AlertSeverity.warning).toList();
      List<StockAlert> danger = alerts.where((a) => a.severity == AlertSeverity.danger).toList();
      
      String alertText = "🚨 **Stock Alerts Summary**\n\n";
      
      if (danger.isNotEmpty) {
        alertText += "**🔴 OUT OF STOCK (${danger.length})**\n";
        alertText += danger.take(3).map((alert) => "• ${alert.productName}").join('\n');
        if (danger.length > 3) alertText += "\n• ...and ${danger.length - 3} more";
        alertText += "\n\n";
      }
      
      if (critical.isNotEmpty) {
        alertText += "**🟠 CRITICAL STOCK (${critical.length})**\n";
        alertText += critical.take(3).map((alert) => "• ${alert.productName} (${alert.currentStock} left)").join('\n');
        if (critical.length > 3) alertText += "\n• ...and ${critical.length - 3} more";
        alertText += "\n\n";
      }
      
      if (warning.isNotEmpty) {
        alertText += "**🟡 LOW STOCK (${warning.length})**\n";
        alertText += warning.take(3).map((alert) => "• ${alert.productName} (${alert.currentStock} left)").join('\n');
        if (warning.length > 3) alertText += "\n• ...and ${warning.length - 3} more";
      }
      
      return ChatResponse(
        text: alertText,
        type: ChatResponseType.data,
        data: {
          'alerts': alerts.map((alert) => {
            'name': alert.productName,
            'stock': alert.currentStock,
            'severity': alert.severity.toString(),
            'category': alert.category,
          }).toList(),
        },
        suggestions: [
          {'text': 'View alerts page', 'action': 'navigate_alerts'},
          {'text': 'Create reorder list', 'action': 'reorder_list'},
          {'text': 'Update stock levels', 'action': 'update_stock'},
        ],
      );
    } catch (e) {
      return ChatResponse(
        text: "I couldn't check stock alerts right now. Please try again later.",
        type: ChatResponseType.error,
      );
    }
  }

  // Handle Report queries
  Future<ChatResponse> _handleReportQuery(String message, Map<String, dynamic> entities) async {
    try {
      if (message.contains('sales')) {
        Map<String, dynamic> salesReport = await _reportsService.generateSalesReport();
        Map<String, dynamic> data = salesReport['data'];
        
        return ChatResponse(
          text: "📈 **Sales Report Summary**\n\n"
                "• **Total Sales**: \$${data['totalSales']?.toStringAsFixed(2) ?? '0.00'}\n"
                "• **Orders**: ${data['totalOrders'] ?? 0}\n"
                "• **Top Product**: ${data['topProduct'] ?? 'N/A'}\n"
                "• **Items Sold**: ${data['itemsSold'] ?? 0}",
          type: ChatResponseType.data,
          data: data,
          suggestions: [
            {'text': 'Detailed sales report', 'action': 'detailed_sales_report'},
            {'text': 'Monthly breakdown', 'action': 'monthly_sales'},
            {'text': 'Export report', 'action': 'export_sales'},
          ],
        );
      } else if (message.contains('inventory')) {
        Map<String, dynamic> inventoryReport = await _reportsService.generateInventoryReport();
        Map<String, dynamic> data = inventoryReport['data'];
        
        return ChatResponse(
          text: "📦 **Inventory Report Summary**\n\n"
                "• **Total Items**: ${data['totalItems'] ?? 0}\n"
                "• **Low Stock**: ${data['lowStock'] ?? 0}\n"
                "• **Out of Stock**: ${data['outOfStock'] ?? 0}\n"
                "• **Total Value**: \$${data['totalValue']?.toStringAsFixed(2) ?? '0.00'}",
          type: ChatResponseType.data,
          data: data,
          suggestions: [
            {'text': 'View detailed report', 'action': 'detailed_inventory_report'},
            {'text': 'Stock alerts', 'action': 'stock_alerts'},
            {'text': 'Reorder suggestions', 'action': 'reorder_suggestions'},
          ],
        );
      } else if (message.contains('customer')) {
        Map<String, dynamic> customerReport = await _reportsService.generateCustomerReport();
        Map<String, dynamic> data = customerReport['data'];
        
        return ChatResponse(
          text: "👥 **Customer Report Summary**\n\n"
                "• **Total Customers**: ${data['totalCustomers'] ?? 0}\n"
                "• **This Month**: ${data['monthlyCustomers'] ?? 0}\n"
                "• **Repeat Customers**: ${data['repeatCustomers'] ?? 0}",
          type: ChatResponseType.data,
          data: data,
          suggestions: [
            {'text': 'Customer insights', 'action': 'customer_insights'},
            {'text': 'Loyalty analysis', 'action': 'loyalty_analysis'},
            {'text': 'Marketing suggestions', 'action': 'marketing_tips'},
          ],
        );
      }
      
      return ChatResponse(
        text: "I can generate various reports for you:\n• Sales performance reports\n• Inventory status reports\n• Customer analytics\n• Business summaries",
        suggestions: [
          {'text': 'Generate sales report', 'action': 'sales_report'},
          {'text': 'Generate inventory report', 'action': 'inventory_report'},
          {'text': 'Generate customer report', 'action': 'customer_report'},
        ],
      );
    } catch (e) {
      return ChatResponse(
        text: "I couldn't generate reports right now. Please try again later.",
        type: ChatResponseType.error,
      );
    }
  }

  // Handle Customer queries
  Future<ChatResponse> _handleCustomerQuery(String message, Map<String, dynamic> entities) async {
    try {
      Map<String, dynamic> customerReport = await _reportsService.generateCustomerReport();
      Map<String, dynamic> data = customerReport['data'];
      
      return ChatResponse(
        text: "👥 **Customer Analytics**\n\n"
              "• **Total Customers**: ${data['totalCustomers'] ?? 0}\n"
              "• **Active This Month**: ${data['monthlyCustomers'] ?? 0}\n"
              "• **Repeat Customers**: ${data['repeatCustomers'] ?? 0}\n"
              "• **New Customers**: ${(data['totalCustomers'] ?? 0) - (data['repeatCustomers'] ?? 0)}",
        type: ChatResponseType.data,
        data: data,
        suggestions: [
          {'text': 'Customer growth trends', 'action': 'customer_trends'},
          {'text': 'Top customers', 'action': 'top_customers'},
          {'text': 'Customer retention tips', 'action': 'retention_tips'},
        ],
      );
    } catch (e) {
      return ChatResponse(
        text: "I couldn't retrieve customer data right now. Please try again later.",
        type: ChatResponseType.error,
      );
    }
  }

  // Handle Action queries (navigation, system actions)
  Future<ChatResponse> _handleActionQuery(String message, List<String> intents, Map<String, dynamic> entities) async {
    if (intents.contains('action_add') && message.contains('product')) {
      return ChatResponse(
        text: "I'll help you add a new product! You can:\n\n1. Navigate to **Add Product** page\n2. Fill in product details\n3. Set initial stock quantity\n\nWould you like me to take you there?",
        type: ChatResponseType.action,
        suggestions: [
          {'text': 'Go to Add Product', 'action': 'navigate_add_product'},
          {'text': 'Product adding tips', 'action': 'add_product_tips'},
          {'text': 'Bulk upload products', 'action': 'bulk_upload'},
        ],
      );
    }
    
    if (intents.contains('action_search')) {
      return ChatResponse(
        text: "I can help you search for:\n• **Products** - Find items in your inventory\n• **Sales** - Look up past transactions\n• **Customers** - Find customer information\n• **Reports** - Locate specific reports\n\nWhat would you like to search for?",
        suggestions: [
          {'text': 'Search products', 'action': 'search_products'},
          {'text': 'Search sales', 'action': 'search_sales'},
          {'text': 'Find reports', 'action': 'search_reports'},
        ],
      );
    }
    
    return ChatResponse(
      text: "I can help you with various actions! Try asking me to:\n• Add new products\n• Search for information\n• Generate reports\n• Navigate to different pages",
      suggestions: [
        {'text': 'Add new product', 'action': 'add_product'},
        {'text': 'Search inventory', 'action': 'search_products'},
        {'text': 'View dashboard', 'action': 'dashboard'},
      ],
    );
  }

  // Handle Help queries
  ChatResponse _handleHelpQuery(String message) {
    if (message.contains('product') || message.contains('inventory')) {
      return ChatResponse(
        text: "🎯 **Product Management Help**\n\n"
              "**I can help you with:**\n"
              "• Check inventory levels\n"
              "• Find products by name\n"
              "• Get stock alerts\n"
              "• Add/edit products\n"
              "• View low stock items\n\n"
              "**Try asking:**\n"
              "• \"How many products do I have?\"\n"
              "• \"Show me low stock items\"\n"
              "• \"Find paracetamol in inventory\"",
        suggestions: [
          {'text': 'Show all features', 'action': 'all_features'},
          {'text': 'Product tutorials', 'action': 'product_tutorials'},
          {'text': 'Quick start guide', 'action': 'quick_start'},
        ],
      );
    }
    
    if (message.contains('sales') || message.contains('order')) {
      return ChatResponse(
        text: "💰 **Sales & Orders Help**\n\n"
              "**I can help you with:**\n"
              "• Check today's sales\n"
              "• View revenue statistics\n"
              "• Find top-selling products\n"
              "• Create new orders\n"
              "• Generate sales reports\n\n"
              "**Try asking:**\n"
              "• \"What are today's sales?\"\n"
              "• \"Show me total revenue\"\n"
              "• \"What's my best-selling product?\"",
        suggestions: [
          {'text': 'Sales tutorials', 'action': 'sales_tutorials'},
          {'text': 'POS system guide', 'action': 'pos_guide'},
          {'text': 'Order management', 'action': 'order_management'},
        ],
      );
    }
    
    return ChatResponse(
      text: "🤖 **HealSearch Assistant Help**\n\n"
            "I'm your intelligent business assistant! I can help with:\n\n"
            "📊 **Analytics & Reports**\n"
            "• Sales performance\n"
            "• Inventory insights\n"
            "• Customer analytics\n\n"
            "🏪 **Inventory Management**\n"
            "• Stock level monitoring\n"
            "• Low stock alerts\n"
            "• Product search\n\n"
            "💼 **Business Operations**\n"
            "• Daily sales summaries\n"
            "• Revenue tracking\n"
            "• Order management\n\n"
            "**Just ask me anything in natural language!**",
      suggestions: [
        {'text': 'Show today\'s summary', 'action': 'daily_summary'},
        {'text': 'Check stock alerts', 'action': 'stock_alerts'},
        {'text': 'View all features', 'action': 'all_features'},
      ],
    );
  }

  // Handle general conversation
  ChatResponse _handleGeneralQuery(String message) {
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      List<String> greetings = [
        "Hello! I'm your AI business assistant. How can I help you today?",
        "Hi there! Ready to explore your business data and insights?",
        "Hey! I'm here to help with your inventory, sales, and business analytics!",
      ];
      
      return ChatResponse(
        text: greetings[Random().nextInt(greetings.length)],
        suggestions: [
          {'text': 'Show today\'s summary', 'action': 'daily_summary'},
          {'text': 'Check inventory status', 'action': 'inventory_status'},
          {'text': 'What can you do?', 'action': 'capabilities'},
        ],
      );
    }
    
    if (message.contains('thank')) {
      return ChatResponse(
        text: "You're very welcome! I'm always here to help you manage your business more effectively. Feel free to ask me anything!",
        suggestions: [
          {'text': 'View business dashboard', 'action': 'dashboard'},
          {'text': 'Generate a report', 'action': 'generate_report'},
          {'text': 'Check notifications', 'action': 'notifications'},
        ],
      );
    }
    
    // Default intelligent responses with business context
    List<String> defaultResponses = [
      "I'm not quite sure what you're looking for. Could you try asking about your sales, inventory, or customers?",
      "That's an interesting question! I specialize in business analytics and inventory management. What specific information do you need?",
      "I'd love to help! Try asking me about your products, sales performance, or stock levels.",
      "I'm here to provide business insights and help manage your inventory. What would you like to know?",
    ];
    
    return ChatResponse(
      text: defaultResponses[Random().nextInt(defaultResponses.length)],
      suggestions: [
        {'text': 'Show business overview', 'action': 'business_overview'},
        {'text': 'What can you help with?', 'action': 'help_topics'},
        {'text': 'Quick sales check', 'action': 'quick_sales'},
      ],
    );
  }

  // Get daily business summary
  Future<ChatResponse> getDailySummary() async {
    try {
      // Get today's sales
      List<Map<String, dynamic>> todaySales = await _salesService.getTodaySales();
      double todayRevenue = todaySales.fold(0.0, (sum, sale) => 
          sum + ((sale['total'] as num?)?.toDouble() ?? 0.0));
      
      // Get stock alerts
      List<StockAlert> alerts = _stockAlertService.activeAlerts;
      int criticalAlerts = alerts.where((a) => 
          a.severity == AlertSeverity.critical || a.severity == AlertSeverity.danger).length;
      
      // Get total products
      List<Map<String, dynamic>> products = await _firebaseService.getProducts();
      
      String summary = "📋 **Daily Business Summary**\n\n";
      summary += "**Today's Performance:**\n";
      summary += "• Orders: ${todaySales.length}\n";
      summary += "• Revenue: \$${todayRevenue.toStringAsFixed(2)}\n\n";
      summary += "**Inventory Status:**\n";
      summary += "• Total Products: ${products.length}\n";
      summary += "• Alerts: ${alerts.length}${criticalAlerts > 0 ? ' (⚠️ $criticalAlerts critical)' : ''}\n\n";
      
      if (criticalAlerts > 0) {
        summary += "**⚠️ Immediate Attention Needed:**\n";
        summary += "• $criticalAlerts products need restocking\n";
      } else {
        summary += "**✅ All Systems Good:**\n";
        summary += "• No critical stock issues\n";
      }
      
      return ChatResponse(
        text: summary,
        type: ChatResponseType.data,
        data: {
          'todaySales': todaySales.length,
          'todayRevenue': todayRevenue,
          'totalProducts': products.length,
          'alerts': alerts.length,
          'criticalAlerts': criticalAlerts,
        },
        suggestions: [
          {'text': 'View detailed sales', 'action': 'detailed_sales'},
          {'text': 'Check stock alerts', 'action': 'stock_alerts'},
          {'text': 'Business analytics', 'action': 'analytics'},
        ],
      );
    } catch (e) {
      return ChatResponse(
        text: "I couldn't generate the daily summary right now. Please try again later.",
        type: ChatResponseType.error,
      );
    }
  }

  // Get smart suggestions based on business data
  Future<List<Map<String, String>>> getSmartSuggestions() async {
    try {
      List<Map<String, String>> suggestions = [];
      
      // Check for immediate business needs
      List<StockAlert> alerts = _stockAlertService.activeAlerts;
      if (alerts.isNotEmpty) {
        suggestions.add({'text': 'Check ${alerts.length} stock alerts', 'action': 'stock_alerts'});
      }
      
      // Check today's performance
      List<Map<String, dynamic>> todaySales = await _salesService.getTodaySales();
      if (todaySales.isEmpty) {
        suggestions.add({'text': 'No sales today - check marketing', 'action': 'marketing_tips'});
      } else {
        suggestions.add({'text': '${todaySales.length} orders today - view details', 'action': 'today_sales'});
      }
      
      // Add general helpful suggestions
      suggestions.addAll([
        {'text': 'What are my top products?', 'action': 'top_products'},
        {'text': 'Show business summary', 'action': 'business_summary'},
        {'text': 'Generate sales report', 'action': 'sales_report'},
      ]);
      
      return suggestions.take(6).toList();
    } catch (e) {
      return [
        {'text': 'Show today\'s summary', 'action': 'daily_summary'},
        {'text': 'Check inventory status', 'action': 'inventory_status'},
        {'text': 'View business dashboard', 'action': 'dashboard'},
      ];
    }
  }
}
