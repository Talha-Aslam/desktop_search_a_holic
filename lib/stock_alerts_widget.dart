import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/stock_alert_service.dart';

class StockAlertsWidget extends StatelessWidget {
  final bool showCompact;
  final VoidCallback? onViewAll;

  const StockAlertsWidget({
    super.key,
    this.showCompact = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<StockAlertService>(
      builder: (context, stockAlertService, child) {
        try {
          if (stockAlertService.activeAlerts.isEmpty) {
            return showCompact
                ? const SizedBox.shrink()
                : _buildEmptyState(themeProvider);
          }

          return showCompact
              ? _buildCompactView(context, stockAlertService, themeProvider)
              : _buildFullView(context, stockAlertService, themeProvider);
        } catch (e) {
          print('Error in StockAlertsWidget: $e');
          return showCompact
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Stock alerts temporarily unavailable',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                );
        }
      },
    );
  }

  Widget _buildCompactView(BuildContext context, StockAlertService service,
      ThemeProvider themeProvider) {
    final criticalCount = service.criticalAlerts + service.outOfStockAlerts;

    if (criticalCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$criticalCount critical stock alert${criticalCount > 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullView(BuildContext context, StockAlertService service,
      ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: themeProvider.cardBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.gradientColors[0].withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: themeProvider.gradientColors[0],
                ),
                const SizedBox(width: 8),
                Text(
                  'Stock Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const Spacer(),
                _buildAlertSummary(service, themeProvider),
              ],
            ),
          ),

          // Alert list
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: service.activeAlerts.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: themeProvider.textColor.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final alert = service.activeAlerts[index];
                return _buildAlertItem(context, alert, themeProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSummary(
      StockAlertService service, ThemeProvider themeProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (service.outOfStockAlerts > 0) ...[
          _buildSummaryChip(
            '${service.outOfStockAlerts}',
            'Out of Stock',
            Colors.red,
          ),
          const SizedBox(width: 4),
        ],
        if (service.criticalAlerts > 0) ...[
          _buildSummaryChip(
            '${service.criticalAlerts}',
            'Critical',
            Colors.orange,
          ),
          const SizedBox(width: 4),
        ],
        if (service.lowStockAlerts > 0) ...[
          _buildSummaryChip(
            '${service.lowStockAlerts}',
            'Low Stock',
            Colors.yellow.shade700,
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryChip(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAlertItem(
      BuildContext context, StockAlert alert, ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: alert.severity.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          alert.severity.icon,
          color: alert.severity.color,
          size: 20,
        ),
      ),
      title: Text(
        alert.productName,
        style: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.message,
            style: TextStyle(
              color: themeProvider.textColor.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                alert.category,
                style: TextStyle(
                  color: themeProvider.textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${alert.timeAgo}',
                style: TextStyle(
                  color: themeProvider.textColor.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: alert.severity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${alert.currentStock}',
              style: TextStyle(
                color: alert.severity.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'in stock',
            style: TextStyle(
              color: themeProvider.textColor.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
      onTap: () => _showAlertDetails(context, alert, themeProvider),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: themeProvider.cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'All Products Well Stocked',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No stock alerts at this time',
              style: TextStyle(
                color: themeProvider.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetails(
      BuildContext context, StockAlert alert, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardBackgroundColor,
        title: Row(
          children: [
            Icon(
              alert.severity.icon,
              color: alert.severity.color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.productName,
                style: TextStyle(color: themeProvider.textColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Status', alert.severity.label, alert.severity.color),
            const SizedBox(height: 8),
            _buildDetailRow('Current Stock', '${alert.currentStock} units',
                themeProvider.textColor),
            const SizedBox(height: 8),
            _buildDetailRow(
                'Category', alert.category, themeProvider.textColor),
            const SizedBox(height: 8),
            _buildDetailRow(
                'Alert Time', alert.timeAgo, themeProvider.textColor),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alert.severity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: alert.severity.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.actionRequired,
                      style: TextStyle(
                        color: alert.severity.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/editProduct',
                arguments: {'productId': alert.productId},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.gradientColors[0],
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Stock Status Indicator Widget
class StockStatusIndicator extends StatelessWidget {
  final int quantity;
  final bool showLabel;

  const StockStatusIndicator({
    super.key,
    required this.quantity,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StockAlertService>(
      builder: (context, stockAlertService, child) {
        final status = stockAlertService.getProductStockStatus(quantity);
        final color = stockAlertService.getStockStatusColor(status);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getStatusLabel(StockStatus status) {
    switch (status) {
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.critical:
        return 'Critical';
      case StockStatus.low:
        return 'Low Stock';
      case StockStatus.normal:
        return 'In Stock';
    }
  }
}
