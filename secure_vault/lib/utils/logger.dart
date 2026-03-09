import 'dart:developer' as developer;

/// Simple logger utility to replace print statements in production code
class Logger {
  static const String _tag = 'SecureVault';

  /// Log debug messages
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      level: 500,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info messages
  static void info(String message) {
    developer.log(message, level: 800, name: _tag);
  }

  /// Log warning messages
  static void warning(String message) {
    developer.log(message, level: 900, name: _tag);
  }

  /// Log error messages
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      level: 1000,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
