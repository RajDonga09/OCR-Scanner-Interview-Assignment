import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal logger wrapping `dart:developer` so callers do not need to know
/// the underlying implementation.
///
/// The logger is intentionally tiny — for a real production app this would
/// be swapped for `logger` / `talker`, but the public API would stay the same.
class AppLogger {
  const AppLogger._();

  static void debug(String message, {String tag = 'OCR'}) {
    if (!kDebugMode) return;
    developer.log(message, name: tag);
  }

  static void info(String message, {String tag = 'OCR'}) {
    developer.log(message, name: tag);
  }

  static void error(
    String message, {
    String tag = 'OCR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
