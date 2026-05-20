import '../constants/app_regex.dart';
import 'extensions.dart';

/// Generic helpers used by feature-specific parsers.
///
/// We deliberately keep these stateless — they are bread-and-butter string
/// manipulation utilities and live in `core/` because both card and passbook
/// parsers consume them.
class ParserHelper {
  const ParserHelper._();

  /// Returns the digit-only representation of [input].
  static String digitsOnly(String input) =>
      input.replaceAll(AppRegex.nonDigits, '');

  /// Masks a card number, displaying only the last [visible] digits.
  ///
  /// Example: `1234567890123456` → `XXXX XXXX XXXX 3456`.
  static String maskCardNumber(String digits, {int visible = 4}) {
    if (digits.length <= visible) return digits;
    final masked = 'X' * (digits.length - visible);
    final tail = digits.substring(digits.length - visible);
    return _groupInFours('$masked$tail');
  }

  /// Pretty-prints a card number into 4-digit groups separated by spaces.
  static String formatCardNumber(String digits) => _groupInFours(digits);

  /// Returns the longest digit run within [text], optionally constrained by
  /// minimum [minLength] and maximum [maxLength] (inclusive).
  ///
  /// This is the workhorse used when an OCR line clearly contains a number
  /// surrounded by descriptive text such as `Account No 1234567890`.
  static String? longestDigitRun(
    String text, {
    int minLength = 1,
    int maxLength = 32,
  }) {
    final matches = RegExp(r'\d+').allMatches(text);
    String? best;
    for (final match in matches) {
      final candidate = match.group(0)!;
      if (candidate.length < minLength) continue;
      if (candidate.length > maxLength) continue;
      if (best == null || candidate.length > best.length) {
        best = candidate;
      }
    }
    return best;
  }

  /// Returns the candidate name from a multi-line block.
  ///
  /// Strategy:
  ///   1. Skip blank / numeric lines.
  ///   2. Skip lines that match any of the provided [exclusions]
  ///      (e.g. bank keywords for the passbook parser).
  ///   3. Prefer lines that contain only letters in uppercase.
  ///   4. Fall back to the first non-numeric letter-heavy line.
  static String? bestNameCandidate(
    Iterable<String> lines, {
    Iterable<RegExp> exclusions = const <RegExp>[],
  }) {
    String? fallback;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (RegExp(r'\d').hasMatch(line)) continue;

      final excluded = exclusions.any((r) => r.hasMatch(line));
      if (excluded) continue;

      final letters = line.replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (letters.length < 4) continue;

      if (AppRegex.humanName.hasMatch(line)) return line.collapseWhitespace();

      // Fall back to the first long-ish letter line we see.
      fallback ??= line.collapseWhitespace();
    }

    return fallback;
  }

  static String _groupInFours(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(input[i]);
    }
    return buffer.toString();
  }
}
