import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/core/utils/text_cleaner.dart';

void main() {
  group('TextCleaner.clean', () {
    test('returns empty string when input is empty', () {
      expect(TextCleaner.clean(''), '');
    });

    test('collapses multiple spaces within a line', () {
      final input = 'FOO     BAR';
      expect(TextCleaner.clean(input), 'FOO BAR');
    });

    test('removes noise characters but keeps allowed punctuation', () {
      final input = '★ JOHN DOE ★\n#1234-5678#';
      final result = TextCleaner.clean(input);
      expect(result.contains('JOHN DOE'), isTrue);
      expect(result.contains('1234-5678'), isTrue);
      expect(result.contains('★'), isFalse);
      expect(result.contains('#'), isFalse);
    });

    test('removes duplicate lines case-insensitively', () {
      final input = 'JOHN DOE\njohn doe\nJOHN DOE';
      final result = TextCleaner.clean(input);
      expect(result.split('\n').length, 1);
    });

    test('drops empty lines after cleaning', () {
      final input = 'A\n\n   \nB';
      expect(TextCleaner.clean(input).split('\n'), ['A', 'B']);
    });
  });

  group('TextCleaner.toLines', () {
    test('splits cleaned text into trimmed non-empty lines', () {
      final lines = TextCleaner.toLines('A\n B \n\nC');
      expect(lines, ['A', 'B', 'C']);
    });

    test('returns empty list for empty input', () {
      expect(TextCleaner.toLines(''), isEmpty);
    });
  });

  group('TextCleaner.normaliseDigits', () {
    test('maps confusable letters to digits', () {
      expect(TextCleaner.normaliseDigits('OISBZ'), '01582');
    });

    test('preserves digits and unrelated characters', () {
      expect(TextCleaner.normaliseDigits('1234 5678'), '1234 5678');
    });

    test('handles lowercase confusables', () {
      expect(TextCleaner.normaliseDigits('ols'), '015');
    });

    test('returns empty input as-is', () {
      expect(TextCleaner.normaliseDigits(''), '');
    });
  });

  group('TextCleaner.normaliseIfsc', () {
    test('uppercases and strips spaces from valid input', () {
      expect(TextCleaner.normaliseIfsc('hdfc 0001234'), 'HDFC0001234');
    });

    test('fixes O to 0 in the reserved 5th position', () {
      expect(TextCleaner.normaliseIfsc('HDFCO001234'), 'HDFC0001234');
    });

    test('fixes digit-OCR confusions in the bank-code prefix', () {
      expect(TextCleaner.normaliseIfsc('HDF50001234'), 'HDFS0001234');
    });

    test('returns the upper-cased value when length differs', () {
      expect(TextCleaner.normaliseIfsc('abcd'), 'ABCD');
    });
  });

  group('TextCleaner.isNumericLine / isAlphabeticLine', () {
    test('correctly detects digit-only lines', () {
      expect(TextCleaner.isNumericLine('1234 5678'), isTrue);
      expect(TextCleaner.isNumericLine('1234A'), isFalse);
    });

    test('correctly detects alphabetic lines', () {
      expect(TextCleaner.isAlphabeticLine('JOHN DOE'), isTrue);
      expect(TextCleaner.isAlphabeticLine('JOHN 4'), isFalse);
    });
  });
}
