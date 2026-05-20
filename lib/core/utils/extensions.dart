import 'package:flutter/material.dart';

/// Small, reusable extensions used across the app.
extension StringExtensions on String {
  /// Returns true when the string contains only whitespace.
  bool get isBlank => trim().isEmpty;

  /// Returns null when the string is blank, otherwise the trimmed value.
  ///
  /// Useful when constructing models where empty strings should become nulls.
  String? get nullIfBlank {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Collapses runs of whitespace into a single space and trims the ends.
  String collapseWhitespace() => replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Returns the string with the first letter of every whitespace-separated
  /// token title-cased.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map(
          (w) =>
              w.length == 1 ? w.toUpperCase() : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element satisfying [test], or null when none does.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  MediaQueryData get mq => MediaQuery.of(this);
  Size get screenSize => mq.size;
}
