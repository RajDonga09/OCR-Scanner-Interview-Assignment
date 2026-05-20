import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/features/card_scanner/domain/models/card_details.dart';
import 'package:ocr_interview_assignment/features/card_scanner/domain/parsers/card_parser.dart';

void main() {
  const parser = CardParser();

  group('CardParser.parseCard - card number extraction', () {
    test('extracts a continuous 16-digit number', () {
      final result = parser.parseCard('''
VISA
4111111111111111
VALID THRU 12/25
JOHN DOE
''');
      expect(result.cardNumber, '4111111111111111');
      expect(result.maskedNumber, 'XXXX XXXX XXXX 1111');
      expect(result.isLuhnValid, isTrue);
      expect(result.brand, CardBrand.visa);
    });

    test('extracts a card number with spaces between groups', () {
      final result = parser.parseCard('''
4111 1111 1111 1111
EXPIRES 12/25
JANE DOE
''');
      expect(result.cardNumber, '4111111111111111');
    });

    test('extracts a card number with dashes between groups', () {
      final result = parser.parseCard('4111-1111-1111-1111\nJOHN DOE');
      expect(result.cardNumber, '4111111111111111');
    });

    test('prefers a Luhn-valid number when multiple candidates exist', () {
      final result = parser.parseCard('''
WRONG 1234567890123456
RIGHT 4111111111111111
''');
      expect(result.cardNumber, '4111111111111111');
      expect(result.isLuhnValid, isTrue);
    });

    test('returns an empty model on empty input', () {
      final result = parser.parseCard('');
      expect(result, CardDetails.empty());
    });

    test('still returns details even when no valid card is detected', () {
      final result = parser.parseCard('JOHN DOE\nVALID THRU 12/25');
      expect(result.cardNumber, isNull);
      expect(result.holderName, 'JOHN DOE');
      expect(result.expiry, '12/25');
    });
  });

  group('CardParser.parseCard - expiry extraction', () {
    test('parses MM/YY format on a VALID THRU line', () {
      final result = parser.parseCard('4111 1111 1111 1111\nVALID THRU 12/25');
      expect(result.expiry, '12/25');
    });

    test('parses MM-YY format on an EXP line', () {
      final result = parser.parseCard('4111 1111 1111 1111\nEXP 09-27');
      expect(result.expiry, '09/27');
    });

    test('parses MMYY without separators', () {
      final result = parser.parseCard('4111 1111 1111 1111\nVALID THRU 0926');
      expect(result.expiry, '09/26');
    });

    test('returns null when expiry is missing', () {
      final result = parser.parseCard('4111 1111 1111 1111\nJOHN DOE');
      expect(result.expiry, isNull);
    });

    test('rejects invalid months', () {
      final result = parser.parseCard('4111 1111 1111 1111\nVALID THRU 13/25');
      expect(result.expiry, isNull);
    });
  });

  group('CardParser.parseCard - card holder extraction', () {
    test('detects an uppercase human name', () {
      final result = parser.parseCard('''
VISA
4111 1111 1111 1111
VALID THRU 12/25
JOHN DOE
''');
      expect(result.holderName, 'JOHN DOE');
    });

    test('ignores VISA / MASTERCARD / VALID THRU / DEBIT lines', () {
      final result = parser.parseCard('''
VISA DEBIT
4111 1111 1111 1111
VALID THRU 12/25
PLATINUM CARD
JANE A SMITH
''');
      expect(result.holderName, 'JANE A SMITH');
    });

    test('returns null when no name candidate is found', () {
      final result = parser.parseCard('''
VISA
4111 1111 1111 1111
VALID THRU 12/25
''');
      expect(result.holderName, isNull);
    });

    test('extracts NAME SURNAME from sample debit card layout', () {
      final result = parser.parseCard('''
DEBIT CARD
1234 5678 9101 8765
09/21
NAME SURNAME
''');
      expect(result.holderName, 'NAME SURNAME');
    });

    test('ignores Smart Chip label and still extracts holder', () {
      final result = parser.parseCard('''
DEBIT CARD
Smart Chip
1234 5678 9101 8765
09/21
NAME SURNAME
''');
      expect(result.holderName, 'NAME SURNAME');
    });

    test('supports title-case holder names from OCR', () {
      final result = parser.parseCard('''
DEBIT CARD
1234 5678 9101 8765
09/21
Name Surname
''');
      expect(result.holderName, 'Name Surname');
    });

    test('merges holder name split across two lines', () {
      final result = parser.parseCard('''
DEBIT CARD
1234 5678 9101 8765
09/21
NAME
SURNAME
''');
      expect(result.holderName, 'NAME SURNAME');
    });
  });

  group('CardParser.parseCard - OCR noise resilience', () {
    test('handles confusable characters in card number', () {
      final result = parser.parseCard('4lll OIII llll llll\nVALID THRU 12/25');
      // After normaliseDigits "4lllOIIIllllllll" → "4111011111111111"
      expect(result.cardNumber?.length, greaterThanOrEqualTo(13));
    });

    test('handles noise symbols in extracted lines', () {
      final result = parser.parseCard('''
*** VISA ***
4111#1111#1111#1111
##VALID THRU 12/25##
@JOHN DOE@
''');
      expect(result.cardNumber, '4111111111111111');
      expect(result.holderName, 'JOHN DOE');
      expect(result.expiry, '12/25');
    });

    test('handles duplicate lines emitted by OCR', () {
      final result = parser.parseCard('''
JOHN DOE
JOHN DOE
4111 1111 1111 1111
4111 1111 1111 1111
VALID THRU 12/25
''');
      expect(result.cardNumber, '4111111111111111');
      expect(result.holderName, 'JOHN DOE');
    });
  });

  group('CardParser.parseCard - brand detection', () {
    test('detects Visa', () {
      final result = parser.parseCard('4111111111111111');
      expect(result.brand, CardBrand.visa);
    });

    test('detects MasterCard (5x range)', () {
      final result = parser.parseCard('5500000000000004');
      expect(result.brand, CardBrand.masterCard);
    });

    test('detects American Express', () {
      final result = parser.parseCard('340000000000009');
      expect(result.brand, CardBrand.amex);
    });
  });

  group('CardParser - copyWith / toJson / fromJson', () {
    test('copyWith only changes the supplied fields', () {
      const original = CardDetails(
        cardNumber: '4111111111111111',
        holderName: 'JOHN DOE',
        expiry: '12/25',
      );
      final copy = original.copyWith(holderName: 'JANE DOE');
      expect(copy.cardNumber, '4111111111111111');
      expect(copy.holderName, 'JANE DOE');
      expect(copy.expiry, '12/25');
    });

    test('toJson / fromJson round-trip', () {
      const original = CardDetails(
        cardNumber: '4111111111111111',
        maskedNumber: 'XXXX XXXX XXXX 1111',
        holderName: 'JOHN DOE',
        expiry: '12/25',
        brand: CardBrand.visa,
        isLuhnValid: true,
      );
      final restored = CardDetails.fromJson(original.toJson());
      expect(restored, original);
    });
  });
}
