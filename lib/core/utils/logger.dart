import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void debug(String message, {String tag = 'OCR'}) {
    if (!kDebugMode) return;
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
