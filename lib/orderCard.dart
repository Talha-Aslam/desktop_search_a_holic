import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';

class OrderCard extends StatelessWidget {
  final String productName;
  final double productPrice;
  final double productQty;
  final String productID;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Map<String, dynamic>? orderDetails;

  const OrderCard({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productQty,
    required this.productID,
    this.onDelete,
    this.onEdit,
    this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: themeProvider.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product name and action buttons
            Row(
              children: [
                // Product icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeProvider.gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: themeProvider.gradientColors[0],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $productID',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: themeProvider.iconColor,
                          size: 20,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Edit Product',
                        splashRadius: 20,
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteConfirmation(context),
                      tooltip: 'Remove from Order',
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price and quantity details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '\$${productPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.gradientColors[0],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${productQty.toInt()} pcs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '\$${(productPrice * productQty).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order details if provided
            if (orderDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.gradientColors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: themeProvider.gradientColors[0].withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (orderDetails!['customerName'] != null)
                      _buildInfoRow(
                        context,
                        'Customer',
                        orderDetails!['customerName'],
                        Icons.person,
                      ),
                    if (orderDetails!['date'] != null)
                      _buildInfoRow(
                        context,
                        'Order Date',
                        orderDetails!['date'],
                        Icons.calendar_today,
                      ),
                    if (orderDetails!['status'] != null)
                      _buildInfoRow(
                        context,
                        'Status',
                        orderDetails!['status'],
                        Icons.info_outline,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: themeProvider.textColor.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.textColor.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: themeProvider.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardBackgroundColor,
        title: Text(
          'Remove Product',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Are you sure you want to remove "$productName" from this order?',
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$productName removed from order'),
                    backgroundColor: Colors.green,
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: Colors.white,
                      onPressed: () {
                        // Could implement undo logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Undo functionality not implemented'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
