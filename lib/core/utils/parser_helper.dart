import 'package:ocr_interview_assignment/core/core.dart';

class ParserHelper {
  const ParserHelper._();

  static final RegExp _titleCaseName = RegExp(
    r"^[A-Z][a-z]+(?:\s+[A-Z][a-z]+){1,4}$",
  );

  static String digitsOnly(String input) =>
      input.replaceAll(AppRegex.nonDigits, '');

  static String maskCardNumber(String digits, {int visible = 4}) {
    if (digits.length <= visible) return digits;
    final masked = 'X' * (digits.length - visible);
    final tail = digits.substring(digits.length - visible);
    return _groupInFours('$masked$tail');
  }

  static String formatCardNumber(String digits) => _groupInFours(digits);

  static String? bestNameCandidate(
    Iterable<String> lines, {
    Iterable<RegExp> exclusions = const <RegExp>[],
  }) {
    String? fallback;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (RegExp(r'\d').hasMatch(line)) continue;

      if (exclusions.any((regex) => regex.hasMatch(line))) continue;

      final letters = line.replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (letters.length < 4) continue;

      final upper = line.toUpperCase();
      if (AppRegex.humanName.hasMatch(upper) || _titleCaseName.hasMatch(line)) {
        return line.collapseWhitespace();
      }

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
