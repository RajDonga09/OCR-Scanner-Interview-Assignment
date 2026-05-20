import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/domain/models/bank_details.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/domain/parsers/passbook_parser.dart';

void main() {
  const parser = PassbookParser();

  group('PassbookParser.parsePassbook - IFSC extraction', () {
    test('extracts a well-formed IFSC code', () {
      final result = parser.parsePassbook('''
STATE BANK OF INDIA
A/C NO: 12345678901
IFSC: SBIN0011234
''');
      expect(result.ifsc, 'SBIN0011234');
      expect(result.isIfscValid, isTrue);
    });

    test('repairs O/0 confusion at position 5', () {
      final result = parser.parsePassbook('IFSC HDFCO001234');
      expect(result.ifsc, 'HDFC0001234');
      expect(result.isIfscValid, isTrue);
    });

    test('returns null IFSC when not present', () {
      final result = parser.parsePassbook('STATE BANK OF INDIA\nJOHN DOE');
      expect(result.ifsc, isNull);
      expect(result.isIfscValid, isFalse);
    });
  });

  group('PassbookParser.parsePassbook - account number extraction', () {
    test('extracts account from an A/C NO line', () {
      final result = parser.parsePassbook('''
JOHN DOE
A/C NO: 123456789012
IFSC: HDFC0001234
''');
      expect(result.accountNumber, '123456789012');
    });

    test('prefers digits adjacent to ACCOUNT keyword over other long numbers',
        () {
      final result = parser.parsePassbook('''
MOBILE: 9876543210
ACCOUNT NO: 987654321012
''');
      expect(result.accountNumber, '987654321012');
    });

    test('ignores Indian mobile numbers as account candidates', () {
      final result = parser.parsePassbook('MOBILE 9876543210');
      expect(result.accountNumber, isNull);
    });

    test('ignores numbers contained in the IFSC code', () {
      final result = parser.parsePassbook('''
IFSC HDFC0001234
ACCOUNT 0001234567
''');
      // `0001234` is part of the IFSC tail, but `0001234567` is longer and is
      // still a valid candidate.
      expect(result.accountNumber, '0001234567');
    });

    test('looks at the next line when the digits sit below the keyword', () {
      final result = parser.parsePassbook('''
ACCOUNT NO
123456789012
''');
      expect(result.accountNumber, '123456789012');
    });

    test('falls back to the longest 9–18 digit run when no keyword is found',
        () {
      final result = parser.parsePassbook('''
HDFC BANK
Some line
JOHN DOE
123456789012
''');
      expect(result.accountNumber, '123456789012');
    });

    test('returns null when no plausible candidate exists', () {
      final result = parser.parsePassbook('JOHN DOE\nIFSC HDFC0001234');
      expect(result.accountNumber, isNull);
    });
  });

  group('PassbookParser.parsePassbook - holder name extraction', () {
    test('detects holder via explicit NAME keyword', () {
      final result = parser.parsePassbook('''
HDFC BANK
NAME: JOHN DOE
A/C 123456789012
''');
      expect(result.accountHolder, 'JOHN DOE');
    });

    test('falls back to the first plausible all-caps line', () {
      final result = parser.parsePassbook('''
HDFC BANK
BRANCH MUMBAI
JOHN A DOE
A/C 123456789012
IFSC HDFC0001234
''');
      expect(result.accountHolder, 'JOHN A DOE');
    });

    test('skips bank / branch / "ACCOUNT" lines', () {
      final result = parser.parsePassbook('''
STATE BANK OF INDIA
BRANCH: MUMBAI
ACCOUNT STATEMENT
JOHN DOE
123456789012
''');
      expect(result.accountHolder, 'JOHN DOE');
    });

    test('returns null when nothing looks like a name', () {
      final result = parser.parsePassbook('1234\n5678');
      expect(result.accountHolder, isNull);
    });
  });

  group('PassbookParser.parsePassbook - SBI passbook layout', () {
    test('extracts customer name, account and IFSC from SBI page', () {
      final result = parser.parsePassbook('''
STATE BANK OF INDIA
CIF No: 89961440164
Account No: 37150529313
Customer Name: Mr. SOUMEN RUIDAS
S/D/W/H/c: BHOLANATH RUIDAS
Branch Name: KULGACHIA BRANCH
IFSC: SBIN0001692
MICR: 700002112
''');
      expect(result.accountHolder, 'SOUMEN RUIDAS');
      expect(result.accountNumber, '37150529313');
      expect(result.ifsc, 'SBIN0001692');
      expect(result.isIfscValid, isTrue);
      expect(result.bankName, contains('STATE BANK'));
      expect(result.branch, contains('KULGACHIA'));
    });

    test('does not pick CIF number as account number', () {
      final result = parser.parsePassbook('''
CIF No: 89961440164
Account No: 37150529313
''');
      expect(result.accountNumber, '37150529313');
    });
  });

  group('PassbookParser.parsePassbook - edge cases', () {
    test('handles empty input', () {
      expect(parser.parsePassbook(''), BankDetails.empty());
    });

    test('handles duplicate lines from OCR', () {
      final result = parser.parsePassbook('''
JOHN DOE
JOHN DOE
A/C 123456789012
A/C 123456789012
IFSC HDFC0001234
IFSC HDFC0001234
''');
      expect(result.accountHolder, 'JOHN DOE');
      expect(result.accountNumber, '123456789012');
      expect(result.ifsc, 'HDFC0001234');
    });

    test('extracts bank name', () {
      final result = parser.parsePassbook('STATE BANK OF INDIA\nJOHN DOE');
      expect(result.bankName, contains('STATE BANK'));
    });

    test('extracts branch', () {
      final result = parser.parsePassbook('BRANCH: MUMBAI\nIFSC HDFC0001234');
      expect(result.branch, 'MUMBAI');
    });

    test('handles partial scans gracefully', () {
      final result = parser.parsePassbook('IFSC HDFC0001234');
      expect(result.ifsc, 'HDFC0001234');
      expect(result.accountNumber, isNull);
      expect(result.accountHolder, isNull);
    });
  });

  group('BankDetails - copyWith / toJson / fromJson', () {
    test('copyWith only changes supplied fields', () {
      const original = BankDetails(
        accountHolder: 'JOHN DOE',
        accountNumber: '12345678',
        ifsc: 'HDFC0001234',
      );
      final copy = original.copyWith(accountHolder: 'JANE DOE');
      expect(copy.accountHolder, 'JANE DOE');
      expect(copy.accountNumber, '12345678');
      expect(copy.ifsc, 'HDFC0001234');
    });

    test('toJson / fromJson round-trip', () {
      const original = BankDetails(
        accountHolder: 'JOHN DOE',
        accountNumber: '123456789012',
        ifsc: 'HDFC0001234',
        bankName: 'HDFC BANK',
        branch: 'MUMBAI',
        isIfscValid: true,
      );
      final restored = BankDetails.fromJson(original.toJson());
      expect(restored, original);
    });
  });
}
