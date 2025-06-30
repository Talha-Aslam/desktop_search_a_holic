import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desktop_search_a_holic/export_service.dart';
import 'package:desktop_search_a_holic/backup_history_service.dart';

class AutoBackupService {
  static final AutoBackupService _instance = AutoBackupService._internal();
  factory AutoBackupService() => _instance;
  AutoBackupService._internal();

  Timer? _backupTimer;
  bool _isDisposed = false;
  final BackupHistoryService _historyService = BackupHistoryService();

  // Default backup interval (24 hours)
  static const Duration _defaultBackupInterval = Duration(hours: 24);

  /// Initialize automatic backup service
  Future<void> initialize() async {
    try {
      if (_isDisposed) return; // Don't initialize if already disposed

      final prefs = await SharedPreferences.getInstance();
      bool autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? true;

      if (autoBackupEnabled && !_isDisposed) {
        await _scheduleNextBackup();
        print('Auto backup service initialized');
      }
    } catch (e) {
      print('Failed to initialize auto backup service: $e');
      // Don't rethrow to prevent app startup issues
    }
  }

  /// Schedule the next automatic backup
  Future<void> _scheduleNextBackup() async {
    if (_isDisposed) return; // Exit if service is disposed

    try {
      // Cancel existing timer if any
      _backupTimer?.cancel();

      // Get last backup time
      DateTime? lastBackup = await _getLastAutoBackupTime();
      DateTime now = DateTime.now();

      Duration timeUntilNextBackup;

      if (lastBackup == null) {
        // No previous backup, schedule one immediately
        timeUntilNextBackup = const Duration(seconds: 10);
      } else {
        // Calculate time until next backup should occur
        DateTime nextBackupTime = lastBackup.add(_defaultBackupInterval);

        if (nextBackupTime.isBefore(now)) {
          // We're overdue for a backup
          timeUntilNextBackup = const Duration(seconds: 30);
        } else {
          timeUntilNextBackup = nextBackupTime.difference(now);
        }
      }

      // Schedule the backup
      _backupTimer = Timer(timeUntilNextBackup, () async {
        if (_isDisposed) return; // Check again before executing
        await _performAutomaticBackup();
        if (!_isDisposed) {
          // Only schedule next if not disposed
          await _scheduleNextBackup(); // Schedule the next one
        }
      });

      print(
          'Next automatic backup scheduled in: ${timeUntilNextBackup.inHours}h ${timeUntilNextBackup.inMinutes % 60}m');
    } catch (e) {
      print('Error scheduling backup: $e');
      if (!_isDisposed) {
        // Retry in 1 hour if there's an error and not disposed
        _backupTimer = Timer(const Duration(hours: 1), () async {
          if (!_isDisposed) {
            await _scheduleNextBackup();
          }
        });
      }
    }
  }

  /// Perform automatic backup
  Future<void> _performAutomaticBackup() async {
    try {
      print('Starting automatic backup...');

      // Check if auto backup is still enabled
      final prefs = await SharedPreferences.getInstance();
      bool autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? true;

      if (!autoBackupEnabled) {
        print('Auto backup disabled, skipping');
        return;
      }

      // Perform the backup
      bool success = await ExportService.createBackup();

      if (success) {
        // Update last backup time
        await _setLastAutoBackupTime(DateTime.now());

        // Log success
        await _historyService.logBackupOperation(
          type: 'automatic',
          status: 'success',
          description: 'Automatic backup completed successfully',
        );

        print('Automatic backup completed successfully');

        // Clean up old backup files if needed
        await _cleanupOldBackups();
      } else {
        await _historyService.logBackupOperation(
          type: 'automatic',
          status: 'failed',
          description: 'Automatic backup failed - general error',
        );
        print('Automatic backup failed');
      }
    } catch (e) {
      await _historyService.logBackupOperation(
        type: 'automatic',
        status: 'failed',
        description: 'Automatic backup failed: $e',
      );
      print('Error during automatic backup: $e');
    }
  }

  /// Clean up old backup files to save space
  Future<void> _cleanupOldBackups() async {
    try {
      Directory? backupDir;

      // Get backup directory
      if (Platform.isWindows) {
        backupDir =
            Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      } else if (Platform.isLinux || Platform.isMacOS) {
        String home = Platform.environment['HOME'] ?? '';
        backupDir = Directory('$home/Downloads');
      }

      if (backupDir == null || !backupDir.existsSync()) {
        return;
      }

      // Find backup files (JSON files with timestamp pattern)
      List<FileSystemEntity> files = backupDir.listSync();
      List<File> backupFiles = [];

      for (var entity in files) {
        if (entity is File &&
            entity.path.contains('backup_') &&
            entity.path.endsWith('.json')) {
          backupFiles.add(entity);
        }
      }

      // Sort by modification date (newest first)
      backupFiles
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Keep only the 10 most recent backups
      const int maxBackupsToKeep = 10;

      if (backupFiles.length > maxBackupsToKeep) {
        List<File> filesToDelete = backupFiles.sublist(maxBackupsToKeep);
        int deletedCount = 0;

        for (File file in filesToDelete) {
          try {
            await file.delete();
            deletedCount++;
          } catch (e) {
            print('Failed to delete old backup file: ${file.path} - $e');
          }
        }

        if (deletedCount > 0) {
          await _historyService.logBackupOperation(
            type: 'cleanup',
            status: 'success',
            description: 'Cleaned up $deletedCount old backup files',
          );
          print('Cleaned up $deletedCount old backup files');
        }
      }
    } catch (e) {
      print('Error during backup cleanup: $e');
    }
  }

  /// Get the last automatic backup time
  Future<DateTime?> _getLastAutoBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? lastBackupStr = prefs.getString('last_auto_backup_time');

      if (lastBackupStr != null) {
        return DateTime.parse(lastBackupStr);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Set the last automatic backup time
  Future<void> _setLastAutoBackupTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_auto_backup_time', time.toIso8601String());
    } catch (e) {
      print('Failed to save last backup time: $e');
    }
  }

  /// Enable automatic backups
  Future<void> enableAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', true);
      await _scheduleNextBackup();
      print('Auto backup enabled');
    } catch (e) {
      print('Failed to enable auto backup: $e');
    }
  }

  /// Disable automatic backups
  Future<void> disableAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', false);
      _backupTimer?.cancel();
      _backupTimer = null;
      print('Auto backup disabled');
    } catch (e) {
      print('Failed to disable auto backup: $e');
    }
  }

  /// Check if auto backup is enabled
  Future<bool> isAutoBackupEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('auto_backup_enabled') ?? true;
    } catch (e) {
      return false;
    }
  }

  /// Get backup status information
  Future<Map<String, dynamic>> getBackupStatus() async {
    try {
      DateTime? lastBackup = await _getLastAutoBackupTime();
      bool isEnabled = await isAutoBackupEnabled();

      // Calculate next backup time
      DateTime? nextBackup;
      if (lastBackup != null && isEnabled) {
        nextBackup = lastBackup.add(_defaultBackupInterval);
      }

      return {
        'isEnabled': isEnabled,
        'lastBackup': lastBackup?.toIso8601String(),
        'nextBackup': nextBackup?.toIso8601String(),
        'backupInterval': _defaultBackupInterval.inHours,
      };
    } catch (e) {
      return {
        'isEnabled': false,
        'error': e.toString(),
      };
    }
  }

  /// Force an immediate backup (for testing)
  Future<bool> triggerBackupNow() async {
    try {
      await _performAutomaticBackup();
      return true;
    } catch (e) {
      print('Failed to trigger backup: $e');
      return false;
    }
  }

  /// Dispose of the service and cleanup resources
  void dispose() {
    _isDisposed = true;
    _backupTimer?.cancel();
    _backupTimer = null;
  }
}
