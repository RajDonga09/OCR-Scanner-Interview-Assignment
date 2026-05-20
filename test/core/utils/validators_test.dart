import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/core/utils/validators.dart';

void main() {
  group('Validators.isCardLengthValid', () {
    test('accepts 13–19 digit numbers', () {
      expect(Validators.isCardLengthValid('4111111111111'), isTrue);
      expect(Validators.isCardLengthValid('4111111111111111'), isTrue);
      expect(Validators.isCardLengthValid('4111111111111111111'), isTrue);
    });

    test('rejects too short / too long sequences', () {
      expect(Validators.isCardLengthValid('123'), isFalse);
      expect(Validators.isCardLengthValid('12345678901234567890'), isFalse);
    });
  });

  group('Validators.isAccountLengthValid', () {
    test('accepts 9–18 digits', () {
      expect(Validators.isAccountLengthValid('123456789'), isTrue);
      expect(Validators.isAccountLengthValid('123456789012345678'), isTrue);
    });

    test('rejects values outside the supported range', () {
      expect(Validators.isAccountLengthValid('12345678'), isFalse);
      expect(Validators.isAccountLengthValid('1234567890123456789'), isFalse);
    });
  });

  group('Validators.isIfscValid', () {
    test('accepts well-formed IFSC codes', () {
      expect(Validators.isIfscValid('HDFC0001234'), isTrue);
      expect(Validators.isIfscValid('SBIN0011234'), isTrue);
      expect(Validators.isIfscValid('ICIC0ABCDEF'), isTrue);
    });

    test('rejects malformed codes', () {
      expect(Validators.isIfscValid(null), isFalse);
      expect(Validators.isIfscValid(''), isFalse);
      expect(Validators.isIfscValid('HDFC1001234'), isFalse);
      expect(Validators.isIfscValid('HDFC000123'), isFalse);
      expect(Validators.isIfscValid('1234567890A'), isFalse);
    });
  });

  group('Validators.isMobileNumber', () {
    test('detects Indian mobile numbers', () {
      expect(Validators.isMobileNumber('9876543210'), isTrue);
      expect(Validators.isMobileNumber('+919876543210'), isTrue);
    });

    test('rejects non-mobile numbers', () {
      expect(Validators.isMobileNumber('1234567890'), isFalse);
      expect(Validators.isMobileNumber('12345'), isFalse);
    });
  });

  group('Validators.isExpiryValid', () {
    test('accepts well-formed MM/YY values', () {
      expect(Validators.isExpiryValid('01/25'), isTrue);
      expect(Validators.isExpiryValid('12/30'), isTrue);
    });

    test('rejects malformed expiries', () {
      expect(Validators.isExpiryValid(null), isFalse);
      expect(Validators.isExpiryValid(''), isFalse);
      expect(Validators.isExpiryValid('13/25'), isFalse);
      expect(Validators.isExpiryValid('00/25'), isFalse);
      expect(Validators.isExpiryValid('1225'), isFalse);
      expect(Validators.isExpiryValid('12-25'), isFalse);
    });
  });
}
