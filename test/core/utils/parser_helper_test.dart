import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/core/core.dart';

void main() {
  group('ParserHelper.digitsOnly', () {
    test('strips non-digit characters', () {
      expect(ParserHelper.digitsOnly('A1 B2-C3'), '123');
      expect(ParserHelper.digitsOnly(''), '');
    });
  });

  group('ParserHelper.maskCardNumber', () {
    test('masks all but the last 4 digits', () {
      expect(
        ParserHelper.maskCardNumber('4111111111111111'),
        'XXXX XXXX XXXX 1111',
      );
    });

    test('returns the input untouched if shorter than visible', () {
      expect(ParserHelper.maskCardNumber('123'), '123');
    });
  });

  group('ParserHelper.formatCardNumber', () {
    test('groups digits into blocks of 4', () {
      expect(
        ParserHelper.formatCardNumber('4111111111111111'),
        '4111 1111 1111 1111',
      );
    });
  });

  group('ParserHelper.bestNameCandidate', () {
    test('prefers all-caps multi-word lines', () {
      final lines = [
        'STATE BANK OF INDIA',
        'JOHN DOE',
        '12345 6789',
      ];
      final exclusions = [RegExp('STATE BANK', caseSensitive: false)];
      expect(
        ParserHelper.bestNameCandidate(lines, exclusions: exclusions),
        'JOHN DOE',
      );
    });

    test('falls back to the first letter-rich line when no full name matches',
        () {
      final lines = ['Account Holder', '12345', 'BRANCH MUMBAI'];
      final exclusions = [RegExp('BRANCH', caseSensitive: false)];
      expect(
        ParserHelper.bestNameCandidate(lines, exclusions: exclusions),
        'Account Holder',
      );
    });

    test('returns null when nothing matches', () {
      expect(
        ParserHelper.bestNameCandidate(['1234', '5678']),
        isNull,
      );
    });
  });
}
