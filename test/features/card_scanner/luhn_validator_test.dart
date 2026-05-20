import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/features/card_scanner/domain/parsers/luhn_validator.dart';

void main() {
  const validator = LuhnValidator();

  group('LuhnValidator.isValidCard', () {
    test('accepts well-known test cards', () {
      const validCards = <String>[
        '4111111111111111', // Visa
        '5500000000000004', // MasterCard
        '340000000000009', // Amex
        '6011000000000004', // Discover
        '4012888888881881',
      ];
      for (final pan in validCards) {
        expect(
          validator.isValidCard(pan),
          isTrue,
          reason: '$pan should pass Luhn',
        );
      }
    });

    test('rejects numbers that flunk the Luhn check', () {
      const invalidCards = <String>[
        '4111111111111112',
        '1234567890123456',
        '4111 1111 1111 1110',
      ];
      for (final pan in invalidCards) {
        expect(
          validator.isValidCard(pan),
          isFalse,
          reason: '$pan should fail Luhn',
        );
      }
    });

    test('ignores spaces and dashes in the input', () {
      expect(validator.isValidCard('4111-1111-1111-1111'), isTrue);
      expect(validator.isValidCard('4111 1111 1111 1111'), isTrue);
    });

    test('rejects too short / too long numbers', () {
      expect(validator.isValidCard('411111'), isFalse);
      expect(validator.isValidCard('41111111111111111111'), isFalse);
    });

    test('rejects empty / non-numeric input', () {
      expect(validator.isValidCard(''), isFalse);
      expect(validator.isValidCard('abcd'), isFalse);
    });
  });
}
