import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/utils/constants.dart';
import 'package:secure_vault/utils/logger.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();

  factory SecurityService() {
    return _instance;
  }

  SecurityService._internal();

  final _storageService = StorageService();
  final _deviceInfo = DeviceInfoPlugin();

  // Get failed attempts count
  Future<int> getFailedAttempts() async {
    try {
      return await _storageService.getInt(AppConstants.failedAttemptsKey) ?? 0;
    } catch (e) {
      Logger.error('SecurityService Error getting failed attempts: $e');
      return 0;
    }
  }

  // Check if account is locked
  Future<bool> isAccountLocked() async {
    try {
      final lockedUntilStr = await _storageService.getString(
        AppConstants.accountLockedUntilKey,
      );
      if (lockedUntilStr == null) return false;

      final lockedUntil = DateTime.parse(lockedUntilStr);
      final now = DateTime.now();

      if (now.isBefore(lockedUntil)) {
        return true;
      } else {
        // Lock has expired, clear it
        await _storageService.delete(AppConstants.accountLockedUntilKey);
        await _storageService.saveInt(AppConstants.failedAttemptsKey, 0);
        return false;
      }
    } catch (e) {
      Logger.error('SecurityService Error checking account lock: $e');
      return false;
    }
  }

  // Increment failed attempts and check if account should be locked
  Future<bool> recordFailedAttempt() async {
    try {
      final failedAttempts =
          await _storageService.getInt(AppConstants.failedAttemptsKey) ?? 0;
      final newAttempts = failedAttempts + 1;

      await _storageService.saveInt(
        AppConstants.failedAttemptsKey,
        newAttempts,
      );

      // Log the failed attempt
      await logAuditEvent('Login Failed', 'Attempt $newAttempts');

      if (newAttempts >= AppConstants.maxFailedAttempts) {
        // Lock the account
        final lockUntil = DateTime.now().add(
          Duration(minutes: AppConstants.accountLockDurationMinutes),
        );
        await _storageService.saveString(
          AppConstants.accountLockedUntilKey,
          lockUntil.toIso8601String(),
        );

        await logAuditEvent(
          'Account Locked',
          'Locked for ${AppConstants.accountLockDurationMinutes} minutes '
              'after ${AppConstants.maxFailedAttempts} failed attempts',
        );

        return true; // Account locked
      }

      return false; // Account not locked yet
    } catch (e) {
      Logger.error('SecurityService Error recording failed attempt: $e');
      return false;
    }
  }

  // Reset failed attempts
  Future<void> resetFailedAttempts() async {
    try {
      await _storageService.delete(AppConstants.failedAttemptsKey);
      await _storageService.delete(AppConstants.accountLockedUntilKey);
      await logAuditEvent('Login Success', 'Failed attempts reset');
    } catch (e) {
      Logger.error('SecurityService Error resetting failed attempts: $e');
    }
  }

  // Check for root/jailbreak
  Future<bool> isDeviceRooted() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        return await _checkIOSJailbreak();
      }
      return false;
    } catch (e) {
      Logger.error('SecurityService Error checking device root: $e');
      return false;
    }
  }

  // Check Android root
  Future<bool> _checkAndroidRoot() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      // Note: This is a basic check. Production apps should use more robust methods
      // or libraries like `flutter_jailbreak_detection`
      final isPhysicalDevice = androidInfo.isPhysicalDevice;
      return !isPhysicalDevice;
    } catch (e) {
      Logger.error('SecurityService Error checking Android root: $e');
      return false;
    }
  }

  // Check iOS jailbreak
  Future<bool> _checkIOSJailbreak() async {
    try {
      const jailbreakIndicators = [
        '/Applications/Cydia.app',
        '/Applications/blackra1n.app',
        '/private/var/lib/apt/',
      ];

      for (final indicator in jailbreakIndicators) {
        final file = File(indicator);
        if (await file.exists()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('SecurityService Error checking iOS jailbreak: $e');
      return false;
    }
  }

  // Log audit events
  Future<void> logAuditEvent(String action, String details) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'action': action,
        'details': details,
      };

      // Get existing logs
      final logsStr = await _storageService.getString(
        AppConstants.auditLogsKey,
      );
      List<dynamic> logs = [];

      if (logsStr != null) {
        logs = jsonDecode(logsStr);
      }

      // Add new log
      logs.add(logEntry);

      // Keep only last 100 logs
      if (logs.length > 100) {
        logs = logs.sublist(logs.length - 100);
      }

      // Save logs
      await _storageService.saveString(
        AppConstants.auditLogsKey,
        jsonEncode(logs),
      );
    } catch (e) {
      Logger.error('SecurityService Error logging audit event: $e');
    }
  }

  // Get audit logs
  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final logsStr = await _storageService.getString(
        AppConstants.auditLogsKey,
      );
      if (logsStr == null) return [];

      final logs = jsonDecode(logsStr) as List<dynamic>;
      return logs.cast<Map<String, dynamic>>();
    } catch (e) {
      Logger.error('SecurityService Error getting audit logs: $e');
      return [];
    }
  }

  // Clear audit logs
  Future<void> clearAuditLogs() async {
    try {
      await _storageService.delete(AppConstants.auditLogsKey);
    } catch (e) {
      Logger.error('SecurityService Error clearing audit logs: $e');
    }
  }
}
