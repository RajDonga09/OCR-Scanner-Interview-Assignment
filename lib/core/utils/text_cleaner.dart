import '../constants/app_regex.dart';

/// Pure, side-effect-free helpers that clean up raw OCR output.
///
/// The OCR engine occasionally confuses similar-looking characters
/// (`O`↔`0`, `I`↔`1`, `S`↔`5`, …). The helpers in this class normalise
/// those errors so the downstream parsers can work on a predictable
/// string regardless of the original photo quality.
///
/// The class only exposes static methods because none of the operations
/// require state — this keeps the API trivial to mock and test.
class TextCleaner {
  const TextCleaner._();

  /// Collapses whitespace runs, strips obvious noise characters and removes
  /// duplicate lines while preserving order.
  ///
  /// The function never modifies the original casing because casing is one of
  /// the strongest signals we have for picking out human names later.
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

      // Drop perfect duplicates – OCR engines often emit the same line twice
      // when the photograph shows reflections or shadows.
      if (!seen.add(collapsed.toUpperCase())) continue;

      cleanedLines.add(collapsed);
    }

    return cleanedLines.join('\n');
  }

  /// Splits cleaned OCR output into non-empty trimmed lines.
  static List<String> toLines(String cleaned) {
    if (cleaned.isEmpty) return const <String>[];
    return cleaned
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  /// Normalises ambiguous OCR characters within a *numeric* context.
  ///
  /// Only call this when you are confident the input is supposed to be a
  /// number — calling it on a name would mangle the name. The mapping is:
  ///
  ///   * `O` / `o` → `0`
  ///   * `I` / `l` / `|` → `1`
  ///   * `S` / `s` → `5`
  ///   * `B`       → `8`
  ///   * `Z`       → `2`
  ///   * `D`       → `0`
  ///   * `Q`       → `0`
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
          break;
        case 'I':
        case 'l':
        case '|':
          buffer.write('1');
          break;
        case 'S':
        case 's':
          buffer.write('5');
          break;
        case 'B':
          buffer.write('8');
          break;
        case 'Z':
          buffer.write('2');
          break;
        default:
          buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Normalises a string that is *supposed* to be an IFSC code.
  ///
  /// IFSC = 4 alphabets + `0` + 6 alphanumerics. We uppercase, strip
  /// whitespace, then nudge the most common OCR slips back into shape.
  static String normaliseIfsc(String input) {
    final upper = input.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (upper.length != 11) return upper;

    final chars = upper.split('');

    // Position 0-3 must be letters: nudge digits back to letters.
    for (var i = 0; i < 4; i++) {
      chars[i] = _digitToLetter(chars[i]);
    }

    // Position 4 must be `0`.
    chars[4] = '0';

    return chars.join();
  }

  /// Returns true when [line] consists exclusively of digits and separators.
  static bool isNumericLine(String line) =>
      AppRegex.digitsOnlyLine.hasMatch(line);

  /// Returns true when [line] only contains letters and standard punctuation.
  static bool isAlphabeticLine(String line) =>
      AppRegex.lettersOnlyLine.hasMatch(line);

  // Reverse of [normaliseDigits] for the alpha portion of an IFSC code.
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
