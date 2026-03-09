import 'dart:async';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/services/security_service.dart';
import 'package:secure_vault/utils/constants.dart';
import 'package:secure_vault/utils/logger.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();

  factory SessionService() {
    return _instance;
  }

  SessionService._internal();

  final _storageService = StorageService();
  final _securityService = SecurityService();

  Timer? _sessionTimer;
  DateTime? _lastActivityTime;

  VoidCallback? _onSessionTimeout;

  // Start session timer
  void startSession(VoidCallback onTimeout) {
    _onSessionTimeout = onTimeout;
    _lastActivityTime = DateTime.now();

    // Create a timer that checks every minute
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (_) async {
      if (_lastActivityTime != null) {
        final elapsed = DateTime.now().difference(_lastActivityTime!);
        if (elapsed.inMinutes > AppConstants.sessionTimeoutMinutes) {
          // Session expired
          await endSession();
          _onSessionTimeout?.call();
        }
      }
    });
  }

  // Update activity time (called on user interaction)
  void updateActivity() {
    _lastActivityTime = DateTime.now();
  }

  // End session
  Future<void> endSession() async {
    try {
      _sessionTimer?.cancel();
      _lastActivityTime = null;
      await _storageService.delete(AppConstants.authTokenKey);
      await _securityService.logAuditEvent(
        'Session Ended',
        'Auto logout due to timeout',
      );
    } catch (e) {
      Logger.error('SessionService Error ending session: $e');
    }
  }

  // Check if session is active
  bool isSessionActive() {
    if (_lastActivityTime == null) return false;
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    return elapsed.inMinutes <= AppConstants.sessionTimeoutMinutes;
  }

  // Get remaining session time in seconds
  int getRemainingSessionTime() {
    if (_lastActivityTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining =
        (AppConstants.sessionTimeoutMinutes * 60) - elapsed.inSeconds;
    return remaining > 0 ? remaining : 0;
  }
}

typedef VoidCallback = void Function();
