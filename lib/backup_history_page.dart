import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:desktop_search_a_holic/backup_history_service.dart';
import 'package:intl/intl.dart';

class BackupHistoryPage extends StatefulWidget {
  const BackupHistoryPage({super.key});

  @override
  _BackupHistoryPageState createState() => _BackupHistoryPageState();
}

class _BackupHistoryPageState extends State<BackupHistoryPage> {
  final BackupHistoryService _historyService = BackupHistoryService();
  List<Map<String, dynamic>> _backupHistory = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String _selectedFilter = 'all';
  bool _isDisposed = false;

  // Store theme provider reference safely
  ThemeProvider? _themeProvider;

  final List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'All Operations'},
    {'value': 'manual', 'label': 'Manual Backups'},
    {'value': 'automatic', 'label': 'Automatic Backups'},
    {'value': 'export', 'label': 'Data Exports'},
    {'value': 'success', 'label': 'Successful Only'},
    {'value': 'failed', 'label': 'Failed Only'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBackupHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store the ThemeProvider reference when dependencies change
    if (!_isDisposed) {
      _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _themeProvider = null; // Clear the reference
    super.dispose();
  }

  Future<void> _loadBackupHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final history = await _historyService.getBackupHistory();
      final stats = await _historyService.getBackupStats();

      setState(() {
        _backupHistory = history;
        _statistics = {
          'totalOperations': stats['totalBackups'] ?? 0,
          'successfulOperations': stats['successfulBackups'] ?? 0,
          'failedOperations': stats['failedBackups'] ?? 0,
          'last24Hours': _countLast24Hours(history),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load backup history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to count operations in last 24 hours
  int _countLast24Hours(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    return history.where((backup) {
      try {
        if (backup['timestamp'] != null) {
          DateTime timestamp;
          if (backup['timestamp'] is String) {
            timestamp = DateTime.parse(backup['timestamp']);
          } else {
            // Handle Firestore Timestamp
            timestamp = (backup['timestamp'] as dynamic).toDate();
          }
          return timestamp.isAfter(yesterday);
        }
        return false;
      } catch (e) {
        return false;
      }
    }).length;
  }

  List<Map<String, dynamic>> _getFilteredHistory() {
    if (_selectedFilter == 'all') {
      return _backupHistory;
    }

    return _backupHistory.where((backup) {
      switch (_selectedFilter) {
        case 'manual':
        case 'automatic':
        case 'export':
          return backup['type'] == _selectedFilter;
        case 'success':
          return backup['status'] == 'success';
        case 'failed':
          return backup['status'] == 'failed';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Backup History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBackupHistory,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: _showCleanupDialog,
            tooltip: 'Cleanup Old Logs',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.scaffoldBackgroundColor,
              ),
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: themeProvider.gradientColors[0],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading backup history...',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Statistics Section
                        if (_statistics != null) _buildStatisticsSection(),

                        // Filter Section
                        _buildFilterSection(),

                        // History List
                        Expanded(
                          child: _buildHistoryList(),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Operations',
                  _statistics!['totalOperations']?.toString() ?? '0',
                  Icons.backup,
                  themeProvider.gradientColors[0],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Successful',
                  _statistics!['successfulOperations']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Failed',
                  _statistics!['failedOperations']?.toString() ?? '0',
                  Icons.error,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Last 24h',
                  _statistics!['last24Hours']?.toString() ?? '0',
                  Icons.schedule,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: themeProvider.gradientColors[0],
          ),
          const SizedBox(width: 8),
          Text(
            'Filter:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              dropdownColor: themeProvider.cardBackgroundColor,
              style: TextStyle(color: themeProvider.textColor),
              underline: Container(),
              items: _filterOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filteredHistory = _getFilteredHistory();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: themeProvider.textColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No backup history found',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Backup operations will appear here',
              style: TextStyle(
                color: themeProvider.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final backup = filteredHistory[index];
        return _buildHistoryItem(backup);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> backup) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    DateTime timestamp;
    try {
      if (backup['timestamp'] is String) {
        timestamp = DateTime.parse(backup['timestamp']);
      } else if (backup['timestamp'] != null) {
        // Handle Firestore Timestamp
        timestamp = (backup['timestamp'] as dynamic).toDate();
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    final String type = backup['type']?.toString() ?? 'unknown';
    final String status = backup['status']?.toString() ?? 'unknown';
    final String description =
        backup['description']?.toString() ?? 'No description';

    Color statusColor = status == 'success' ? Colors.green : Colors.red;
    IconData typeIcon = _getTypeIcon(type);
    IconData statusIcon =
        status == 'success' ? Icons.check_circle : Icons.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: themeProvider.cardBackgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            typeIcon,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              _getTypeLabel(type),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              statusIcon,
              color: statusColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: themeProvider.textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'manual':
        return Icons.backup;
      case 'automatic':
        return Icons.schedule;
      case 'export':
        return Icons.download;
      case 'cleanup':
        return Icons.cleaning_services;
      default:
        return Icons.backup;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'manual':
        return 'Manual Backup';
      case 'automatic':
        return 'Auto Backup';
      case 'export':
        return 'Data Export';
      case 'cleanup':
        return 'Cleanup';
      default:
        return 'Unknown';
    }
  }

  void _showCleanupDialog() {
    if (_isDisposed || _themeProvider == null || !mounted) return;

    final themeProvider = _themeProvider!;
    final pageContext = context; // Store main context safely

    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: themeProvider.cardBackgroundColor,
        title: Text(
          'Cleanup Old Logs',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'This will remove backup history logs older than 30 days. This action cannot be undone.',
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (!mounted || _isDisposed) return;

              try {
                await _historyService.cleanupOldLogs();
                if (mounted && !_isDisposed) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(
                      content: Text('Old logs cleaned up successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadBackupHistory(); // Refresh the list
                }
              } catch (e) {
                if (mounted && !_isDisposed) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cleanup logs: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }
}
