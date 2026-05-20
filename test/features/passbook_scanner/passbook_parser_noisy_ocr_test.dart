import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/domain/parsers/passbook_parser.dart';

void main() {
  const parser = PassbookParser();

  const noisyOcrLog = '''
CIF N
ACCoUa
NO
8996144401.64
S7150529313
Customer Name MrSOUMEN RUIDAS
Phone
Email
S/D/W/H/C:BHOLANATH RUIDAS
Address.S/0-BHOLANATH RUIDAS, VILL-MANIKPUR
PO KUGACHIA PSULUBERTA
MANIKPUR
Di0,8 If Minor:12/02/2007
MOPSINGLE
Nom. Reg. No.00000002113192V1
KELGACHTA BRANCH
VILLMANICKPOR PO KUEGACHIA
hone:
State Bank of India
Emailtsbi l69220s1 co in
Branch Codet1692
Date
02/112017589 512 16922
e0z1/2017
SCSBINQCE6922
MICR7O0a
CON
TINUATAhch Manager
KULGACHIA BRANCH
NK O
''';

  test('parses noisy SBI passbook OCR log from device scan', () {
    final result = parser.parsePassbook(noisyOcrLog);

    expect(result.accountHolder, 'SOUMEN RUIDAS');
    expect(result.accountNumber, '37150529313');
    expect(result.ifsc, 'SBIN0001692');
    expect(result.isIfscValid, isTrue);
    expect(result.bankName, contains('STATE BANK'));
    expect(result.branch, contains('KULGACHIA'));
  });

  test('does not use CIF number as account number in noisy OCR', () {
    final result = parser.parsePassbook(noisyOcrLog);
    expect(result.accountNumber, isNot('89961440164'));
    expect(result.accountNumber, isNot(contains('899614')));
  });
}
