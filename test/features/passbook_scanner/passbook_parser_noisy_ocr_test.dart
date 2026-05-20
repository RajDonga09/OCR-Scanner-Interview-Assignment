import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/passbook_scanner.dart';

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
    // Real IFSC for SBI Kulgachia — must be recovered from the garbled
    // "SCSBINQCE6922" line, not synthesised from the visible branch code.
    expect(result.ifsc, 'SBIN0006922');
    expect(result.isIfscValid, isTrue);
    expect(result.bankName, contains('STATE BANK'));
    expect(result.branch, contains('KULGACHIA'));
  });

  test('does not use CIF number as account number in noisy OCR', () {
    final result = parser.parsePassbook(noisyOcrLog);
    expect(result.accountNumber, isNot('89961440164'));
    expect(result.accountNumber, isNot(contains('899614')));
  });

  test('does not fabricate an IFSC from arbitrary 4-letter OCR noise', () {
    final result = parser.parsePassbook(noisyOcrLog);
    // Earlier versions of the parser combined random prefixes (e.g. "ADDR"
    // from "Address" or "NCHC" from misread text) with the branch code
    // suffix to fabricate IFSCs like "NCHC0001692".
    expect(result.ifsc, isNot(startsWith('ADDR')));
    expect(result.ifsc, isNot(startsWith('NCHC')));
    expect(result.ifsc, isNot(endsWith('001692')));
  });

  // OCR log captured verbatim from the production device scan. The IFSC
  // text appears as `IFSC:SBINOL6922` — the OCR has dropped one character
  // from the 11-char code, leaving 10 alphanumerics after the label.
  const deviceOcrLog = '''
CIF No
Account No :
89961440164
37150529313
Customer Name: Mr. SOUMEN RUIDAS
Phone:
Email:
S/D/W/H/c:BHOLANATH RUIDAS
Address:S/0-BHOLANATH RUIDAS, VILL-MANIKPUR
P.0-KULGACHIA, P.S-ULUBERIA
MANIKPUR
D.0.B. If Minor: 12//02/2007
MOP. :SINGLE
Nom. Reg. No. :0000000211319271
State Bank of India
KULGACHIA BRANCH
VILL: MANICKPUR PO KULGACHIA
Email:sbi.16922si.co .in
Branch Code:1692
Date of Issue:0Z/1/2017
02/11/2017 5395 12 16922
IFSC:SBINOL6922
MICR:700002ReT YGUH
CONTINUAT Ihch Manager
BANK O
''';

  test('parses clean device OCR with a 10-char IFSC after the label', () {
    final result = parser.parsePassbook(deviceOcrLog);

    expect(result.accountHolder, 'SOUMEN RUIDAS');
    expect(result.accountNumber, '37150529313');
    expect(result.accountNumber, isNot('89961440164'));
    expect(result.ifsc, 'SBIN0006922');
    expect(result.isIfscValid, isTrue);
    expect(result.bankName, contains('STATE BANK'));
    expect(result.branch, contains('KULGACHIA'));
  });
}
