import 'package:ocr_interview_assignment/core/core.dart';

class TextCleaner {
  const TextCleaner._();

  static String clean(String raw) {
    if (raw.isEmpty) return '';

    final lines = raw.split('\n');
    final cleanedLines = <String>[];
    final seen = <String>{};

    for (final line in lines) {
      final stripped = line.replaceAll(AppRegex.noise, '').trim();
      if (stripped.isEmpty) continue;

      final collapsed = stripped.replaceAll(AppRegex.whitespace, ' ').trim();
      if (collapsed.isEmpty) continue;

      if (!seen.add(collapsed.toUpperCase())) continue;

      cleanedLines.add(collapsed);
    }

    return cleanedLines.join('\n');
  }

  static List<String> toLines(String cleaned) {
    if (cleaned.isEmpty) return const <String>[];
    return cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  /// Use only on numeric strings (O→0, I/l→1, S→5, B→8, etc.).
  static String normaliseDigits(String input) {
    if (input.isEmpty) return input;

    final buffer = StringBuffer();
    for (final char in input.split('')) {
      switch (char) {
        case 'O':
        case 'o':
        case 'D':
        case 'Q':
          buffer.write('0');
        case 'I':
        case 'l':
        case '|':
          buffer.write('1');
        case 'S':
        case 's':
          buffer.write('5');
        case 'B':
          buffer.write('8');
        case 'Z':
          buffer.write('2');
        default:
          buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String normaliseIfsc(String input) {
    final upper = input.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (upper.length != 11) return upper;

    final chars = upper.split('');
    for (var i = 0; i < 4; i++) {
      chars[i] = _digitToLetter(chars[i]);
    }
    chars[4] = '0';
    return chars.join();
  }

  static bool isNumericLine(String line) =>
      AppRegex.digitsOnlyLine.hasMatch(line);

  static bool isAlphabeticLine(String line) =>
      AppRegex.lettersOnlyLine.hasMatch(line);

  static String _digitToLetter(String char) {
    switch (char) {
      case '0':
        return 'O';
      case '1':
        return 'I';
      case '5':
        return 'S';
      case '8':
        return 'B';
      case '2':
        return 'Z';
      default:
        return char;
    }
  }
}
