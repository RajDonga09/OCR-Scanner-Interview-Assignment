import 'package:ocr_interview_assignment/dependency.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/passbook_scanner.dart';

class PassbookParser {
  const PassbookParser();

  static const Set<String> _knownBankPrefixes = {
    'SBIN',
    'HDFC',
    'ICIC',
    'AXIS',
    'PUNB',
    'CNRB',
    'UTIB',
    'IDFB',
    'KKBK',
    'IOBA',
    'INDB',
    'IBKL',
    'MAHB',
    'BARB',
    'BKID',
    'CBIN',
    'CORP',
    'FDRL',
    'ORBC',
    'PSIB',
    'SCBL',
    'SIBL',
    'SRCB',
    'SYNB',
    'UCBA',
    'UBIN',
    'UTBI',
    'VIJB',
    'YESB',
    'RATN',
    'BOFA',
    'CITI',
    'HSBC',
    'CIUB',
    'JAKA',
    'KARB',
    'TMBL',
    'DCBL',
    'IDIB',
    'IDFC',
    'AUBL',
    'BDBL',
    'ESFB',
    'FINO',
    'PYTM',
    'SURY',
    'UJVN',
    'UTKS',
    'ANDB',
    'DEUT',
  };

  static final RegExp _accountLabelRegex = RegExp(
    r'(ACCOU\w*\s*(NO\.?|NUMBER)?|A\s*/\s*C\s*(NO\.?)?|AC\s*NO)',
    caseSensitive: false,
  );

  BankDetails parsePassbook(String rawText) {
    if (rawText.isEmpty) return BankDetails.empty();

    final lines = _mergeFragmentLines(
      TextCleaner.toLines(TextCleaner.clean(rawText)),
    );
    if (lines.isEmpty) return BankDetails.empty();

    final blob = lines.join(' ');

    final ifsc = _extractIfsc(lines, blob);
    final accountNumber = _extractAccountNumber(lines, blob, ifsc: ifsc);
    final holder = _extractHolderName(lines);
    final bank = _extractBankName(lines);
    final branch = _extractBranch(lines);

    return BankDetails(
      accountHolder: holder,
      accountNumber: accountNumber,
      ifsc: ifsc,
      bankName: bank,
      branch: branch,
      isIfscValid: Validators.isIfscValid(ifsc),
    );
  }

  List<String> _mergeFragmentLines(List<String> lines) {
    final merged = <String>[];
    var i = 0;

    while (i < lines.length) {
      var line = lines[i];
      final trimmed = line.trim();

      if (RegExp(r'^ACC[A-Za-z]*$').hasMatch(trimmed) &&
          i + 1 < lines.length &&
          RegExp(
            r'^NO\.?$',
            caseSensitive: false,
          ).hasMatch(lines[i + 1].trim().toUpperCase())) {
        line = '$line ${lines[++i]}';
      } else if (RegExp(r'^CIF$', caseSensitive: false).hasMatch(trimmed) &&
          i + 1 < lines.length &&
          RegExp(
            r'^N(O\.?|UMBER)?$',
            caseSensitive: false,
          ).hasMatch(lines[i + 1].trim().toUpperCase())) {
        line = '$line ${lines[++i]}';
      }

      merged.add(line);
      i++;
    }

    return _restackColumns(merged);
  }

  List<String> _restackColumns(List<String> lines) {
    for (var start = 0; start < lines.length - 1; start++) {
      if (!_isLabelOnlyLine(lines[start])) continue;

      var labelEnd = start;
      while (labelEnd < lines.length && _isLabelOnlyLine(lines[labelEnd])) {
        labelEnd++;
      }
      final labelCount = labelEnd - start;
      if (labelCount < 2) continue;

      var valueEnd = labelEnd;
      while (valueEnd < lines.length &&
          _isLongDigitValueLine(lines[valueEnd])) {
        valueEnd++;
      }
      final valueCount = valueEnd - labelEnd;
      if (valueCount != labelCount) continue;

      final paired = <String>[];
      for (var k = 0; k < start; k++) {
        paired.add(lines[k]);
      }
      for (var k = 0; k < labelCount; k++) {
        paired.add('${lines[start + k]} ${lines[labelEnd + k]}');
      }
      for (var k = valueEnd; k < lines.length; k++) {
        paired.add(lines[k]);
      }
      return paired;
    }
    return lines;
  }

  bool _isLabelOnlyLine(String line) {
    final upper = line.trim().toUpperCase();
    if (upper.isEmpty) return false;
    final hasLabel =
        RegExp(r'\bCIF\b').hasMatch(upper) ||
        _accountLabelRegex.hasMatch(upper);
    if (!hasLabel) return false;
    final digits = upper.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length < 5;
  }

  bool _isLongDigitValueLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return false;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9 || digits.length > 18) return false;
    final nonNumeric = trimmed.replaceAll(RegExp(r'[0-9\s.]'), '');
    return nonNumeric.length <= 1;
  }

  String? _extractIfsc(List<String> lines, String blob) {
    final candidates = <String, int>{};

    void add(String? code, {required int score}) {
      if (code == null || !Validators.isIfscValid(code)) return;
      final prev = candidates[code];
      final total = score + _leadingZeroBonus(code);
      if (prev == null || total > prev) candidates[code] = total;
    }

    for (final line in lines) {
      if (_isAccountLabelLine(line)) continue;

      final onIfscLine = line.toUpperCase().contains('IFSC');
      for (final code in _ifscCandidatesFromLine(line)) {
        var score = onIfscLine ? 40 : 20;
        if (_knownBankPrefixes.contains(code.substring(0, 4))) {
          score += 30;
        }
        add(code, score: score);
      }
    }

    if (candidates.isEmpty) return null;

    return candidates.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  int _leadingZeroBonus(String ifsc) {
    final tail = ifsc.substring(5);
    var count = 0;
    while (count < tail.length && tail[count] == '0') {
      count++;
    }
    return count * 5;
  }

  Iterable<String> _ifscCandidatesFromLine(String line) {
    final upper = line.toUpperCase();
    if (_isAccountLabelLine(line) && !upper.contains('IFSC')) return const [];
    if (!_lineMayContainIfsc(upper)) return const [];

    final found = <String>{};

    final explicit = RegExp(
      r'IFSC\s*[:\s]*([A-Z0-9]{11})',
      caseSensitive: false,
    ).firstMatch(line);
    if (explicit != null) {
      _addRepairVariants(found, explicit.group(1)!);
    }

    final direct = AppRegex.ifsc.firstMatch(upper);
    if (direct != null) found.add(direct.group(0)!);

    final scanStart = upper.contains('IFSC') ? upper.indexOf('IFSC') + 4 : 0;
    final compact = upper
        .substring(scanStart)
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    for (var i = 0; i <= compact.length - 11; i++) {
      _addRepairVariants(found, compact.substring(i, i + 11));
    }

    if (upper.contains('IFSC')) {
      final shortMatch = RegExp(
        r'IFSC\s*[:\s]*([A-Z0-9]{10})(?![A-Z0-9])',
        caseSensitive: false,
      ).firstMatch(line);
      if (shortMatch != null) {
        final raw = shortMatch.group(1)!.toUpperCase();
        if (_knownBankPrefixes.contains(raw.substring(0, 4))) {
          final padded = '${raw.substring(0, 4)}0${raw.substring(4)}';
          _addRepairVariants(found, padded);
        }
      }
    }

    return found;
  }

  void _addRepairVariants(Set<String> sink, String raw) {
    final base = _repairIfsc(raw);
    if (base != null) sink.add(base);
    final alt = _repairIfsc(raw, lettersPreferZero: true);
    if (alt != null) sink.add(alt);
  }

  bool _isAccountLabelLine(String line) {
    final upper = line.toUpperCase();
    return _accountLabelRegex.hasMatch(upper) ||
        RegExp(r'^ACC(OUNT|OU)', caseSensitive: false).hasMatch(upper);
  }

  bool _lineMayContainIfsc(String upper) {
    if (upper.contains('IFSC')) return true;
    if (RegExp(r'[A-Z]{4}0[A-Z0-9]{5}').hasMatch(upper)) return true;
    for (final prefix in _knownBankPrefixes) {
      if (upper.contains(prefix)) return true;
    }
    return false;
  }

  String? _repairIfsc(String raw, {bool lettersPreferZero = false}) {
    if (raw.length < 11) return null;
    final normalised = TextCleaner.normaliseIfsc(raw.substring(0, 11));
    final tail = normalised.substring(5).split('').map((c) {
      if (lettersPreferZero && (c == 'L' || c == 'I')) return '0';
      return _ocrToDigit(c);
    }).join();
    final result = '${normalised.substring(0, 5)}$tail';
    return Validators.isIfscValid(result) ? result : null;
  }

  String? _extractAccountNumber(
    List<String> lines,
    String blob, {
    String? ifsc,
  }) {
    final cifNumbers = _numbersNearKeyword(
      lines,
      RegExp(r'\bCIF\b', caseSensitive: false),
    );
    final preferred = <String>[];
    final fallback = <String>[];

    final accountLineMatch = _firstAccountLineMatch(lines);
    if (accountLineMatch != null) {
      final fixed = _fixAccountDigits(accountLineMatch);
      if (_isPlausibleAccount(fixed, cifNumbers: cifNumbers, ifsc: ifsc)) {
        preferred.add(fixed);
      }
    } else {
      final blobAccount =
          RegExp(
            r'(?:ACCOUNT|ACC(?:OUNT)?|A\s*/\s*C|ACCOU\w*)\s+NO\s+([A-Z]?\d{9,17})',
            caseSensitive: false,
          ).firstMatch(blob) ??
          RegExp(
            r'(?:ACCOUNT|ACC(?:OUNT)?|A\s*/\s*C)\s*(?:NO|NUMBER)?\s*[:\s]*([A-Z]?\d{9,17})',
            caseSensitive: false,
          ).firstMatch(blob);
      if (blobAccount != null) {
        final fixed = _fixAccountDigits(blobAccount.group(1)!);
        if (_isPlausibleAccount(fixed, cifNumbers: cifNumbers, ifsc: ifsc)) {
          preferred.add(fixed);
        }
      }
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (AppRegex.accountExcludeKeyword.hasMatch(line)) continue;
      if (RegExp(r'\bCIF\b', caseSensitive: false).hasMatch(line)) continue;

      final nearKeyword =
          _accountLabelRegex.hasMatch(line) ||
          (i > 0 && _accountLabelRegex.hasMatch(lines[i - 1]));

      for (final n in _accountDigitsFromLine(line)) {
        if (!_isPlausibleAccount(n, cifNumbers: cifNumbers, ifsc: ifsc)) {
          continue;
        }
        (nearKeyword ? preferred : fallback).add(n);
      }
    }

    if (preferred.isNotEmpty) return _longestUnique(preferred);
    if (fallback.isNotEmpty) return _longestUnique(fallback);
    return null;
  }

  String? _firstAccountLineMatch(List<String> lines) {
    for (final line in lines) {
      if (RegExp(r'\bCIF\b', caseSensitive: false).hasMatch(line)) continue;
      if (!_accountLabelRegex.hasMatch(line)) continue;
      final match = RegExp(
        r'([A-Z]?\d{9,17})',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) return match.group(1);
    }
    return null;
  }

  Set<String> _numbersNearKeyword(List<String> lines, RegExp keyword) {
    final numbers = <String>{};
    for (var i = 0; i < lines.length; i++) {
      if (!keyword.hasMatch(lines[i])) continue;
      numbers.addAll(_accountDigitsFromLine(lines[i]));
      if (i + 1 < lines.length && !_accountLabelRegex.hasMatch(lines[i + 1])) {
        numbers.addAll(_accountDigitsFromLine(lines[i + 1]));
      }
    }
    return numbers;
  }

  List<String> _accountDigitsFromLine(String line) {
    final results = <String>{};

    for (final match in RegExp(r'\d{9,18}').allMatches(line)) {
      results.add(match.group(0)!);
    }

    for (final match in RegExp(
      r'[A-Z]?\d{9,17}',
    ).allMatches(line.toUpperCase())) {
      final fixed = _fixAccountDigits(match.group(0)!);
      if (fixed.length >= 9 && fixed.length <= 18) results.add(fixed);
    }

    return results.toList();
  }

  String _fixAccountDigits(String raw) {
    var s = raw.replaceAll(RegExp(r'[^0-9A-Za-z.]'), '');
    if (s.contains('.')) s = s.split('.').first;
    if (RegExp(r'^S\d{9,}').hasMatch(s)) s = '3${s.substring(1)}';
    return ParserHelper.digitsOnly(s);
  }

  bool _isPlausibleAccount(
    String digits, {
    required Set<String> cifNumbers,
    String? ifsc,
  }) {
    if (!Validators.isAccountLengthValid(digits)) return false;
    if (cifNumbers.contains(digits)) return false;
    if (digits.length == 10 && Validators.isMobileNumber(digits)) return false;
    if (ifsc != null && ifsc.contains(digits)) return false;
    return true;
  }

  String _longestUnique(List<String> values) {
    final unique = values.toSet().toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return unique.first;
  }

  String? _extractHolderName(List<String> lines) {
    for (final line in lines) {
      final match = RegExp(
        r'Customer\s*Name\s*:?\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) return _cleanPersonName(match.group(1)!);
    }

    final explicit = _valueAfterKeyword(lines, AppRegex.nameKeyword);
    if (explicit != null) return _cleanPersonName(explicit);

    return ParserHelper.bestNameCandidate(
      lines,
      exclusions: <RegExp>[
        AppRegex.branchKeyword,
        AppRegex.guardianKeyword,
        RegExp(
          r'(STATE BANK|HDFC|ICICI|AXIS|PUNJAB|CANARA|YES BANK|BANK OF)',
          caseSensitive: false,
        ),
        RegExp(
          r'(SAVINGS|CURRENT|PASSBOOK|ACCOUNT|STATEMENT|CUSTOMER ID|CIF|MICR|NOM|PHONE|EMAIL)',
          caseSensitive: false,
        ),
      ],
    );
  }

  String _cleanPersonName(String raw) {
    var name = raw.trim();
    name = name.replaceFirst(RegExp(r'^Mr\.?\s*', caseSensitive: false), '');
    name = name.replaceFirst(RegExp(r'^Mr(?=[A-Z])', caseSensitive: false), '');
    return name.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _valueAfterKeyword(List<String> lines, RegExp keyword) {
    for (var i = 0; i < lines.length; i++) {
      final match = keyword.firstMatch(lines[i]);
      if (match == null) continue;

      final remainder = lines[i]
          .substring(match.end)
          .trim()
          .replaceFirst(RegExp(r'^[:\-\s]+'), '')
          .trim();
      if (remainder.length >= 3 && !RegExp(r'\d').hasMatch(remainder)) {
        return remainder;
      }

      if (i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (next.isNotEmpty &&
            !RegExp(r'\d').hasMatch(next) &&
            !AppRegex.branchKeyword.hasMatch(next)) {
          return next;
        }
      }
    }
    return null;
  }

  String? _extractBankName(List<String> lines) {
    for (final line in lines) {
      if (RegExp(r'STATE\s*BANK', caseSensitive: false).hasMatch(line)) {
        return 'STATE BANK OF INDIA';
      }
    }
    for (final line in lines) {
      if (RegExp(r'\bBANK\b', caseSensitive: false).hasMatch(line) &&
          line.length < 60) {
        return line.trim();
      }
    }
    return null;
  }

  String? _extractBranch(List<String> lines) {
    final candidates = <_RankedCandidate>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.toUpperCase().contains('BRANCH')) continue;

      final match = RegExp(r'BRANCH', caseSensitive: false).firstMatch(line)!;
      final after = line
          .substring(match.end)
          .replaceFirst(RegExp(r'^[:\-\s]+'), '')
          .trim();
      final before = line.substring(0, match.start).trim();

      if (after.length > 3) candidates.add(_RankedCandidate(after, i));
      if (before.length > 3) {
        candidates.add(_RankedCandidate('$before BRANCH', i));
      }

      if (i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (next.isNotEmpty && !RegExp(r'\d').hasMatch(next)) {
          candidates.add(_RankedCandidate(next, i + 1));
        }
      }
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      final rankDiff = _branchRank(b.value).compareTo(_branchRank(a.value));
      if (rankDiff != 0) return rankDiff;
      return b.position.compareTo(a.position);
    });
    return candidates.first.value;
  }

  int _branchRank(String name) {
    final upper = name.toUpperCase();
    var rank = 0;
    if (upper.contains('BRANCH')) rank += 4;
    if (name.length <= 30) rank += 3;
    if (!RegExp(r'\d').hasMatch(name)) rank += 2;
    if (upper.contains('VILL') ||
        upper.contains(' PO ') ||
        upper.contains('P.O')) {
      rank -= 6;
    }
    return rank;
  }

  static String _ocrToDigit(String char) {
    switch (char) {
      case 'O':
      case 'D':
      case 'Q':
      case 'C':
      case 'E':
        return '0';
      case 'I':
      case 'L':
      case '|':
        return '1';
      case 'S':
        return '5';
      case 'B':
        return '8';
      case 'Z':
        return '2';
      case 'G':
        return '6';
      default:
        return char;
    }
  }
}

class _RankedCandidate {
  const _RankedCandidate(this.value, this.position);

  final String value;
  final int position;
}
