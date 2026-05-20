import '../../../../core/constants/app_regex.dart';
import '../../../../core/utils/parser_helper.dart';
import '../../../../core/utils/text_cleaner.dart';
import '../../../../core/utils/validators.dart';
import '../models/bank_details.dart';

/// Generic passbook parser — works from labelled fields and digit patterns,
/// not bank-specific rules.
class PassbookParser {
  const PassbookParser();

  BankDetails parsePassbook(String rawText) {
    if (rawText.isEmpty) return BankDetails.empty();

    final lines = _mergeFragmentLines(TextCleaner.toLines(TextCleaner.clean(rawText)));
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

  /// OCR often splits labels across lines (`ACCoUa` + `NO` + account digits).
  List<String> _mergeFragmentLines(List<String> lines) {
    final merged = <String>[];
    var i = 0;

    while (i < lines.length) {
      var line = lines[i];
      final upper = line.toUpperCase();

      if (RegExp(r'^ACC', caseSensitive: false).hasMatch(upper) &&
          i + 1 < lines.length &&
          RegExp(r'^NO\.?$', caseSensitive: false).hasMatch(lines[i + 1].toUpperCase())) {
        line = '$line ${lines[++i]}';
        if (i + 1 < lines.length &&
            RegExp(r'^[A-Z]?\d').hasMatch(lines[i + 1])) {
          line = '$line ${lines[++i]}';
        }
      } else if (RegExp(r'^CIF\b', caseSensitive: false).hasMatch(upper) &&
          i + 1 < lines.length &&
          !RegExp(r'^ACC', caseSensitive: false).hasMatch(lines[i + 1].toUpperCase())) {
        line = '$line ${lines[++i]}';
      }

      merged.add(line);
      i++;
    }

    return merged;
  }

  // ── IFSC ──────────────────────────────────────────────────────────────────

  String? _extractIfsc(List<String> lines, String blob) {
    final branchDigits = _branchCodeDigits(blob);
    final candidates = <String, int>{};

    void add(String? code, {required int score}) {
      if (code == null || !Validators.isIfscValid(code)) return;
      final prev = candidates[code];
      if (prev == null || score > prev) candidates[code] = score;
    }

    for (final line in lines) {
      if (_isAccountLabelLine(line)) continue;

      final onIfscLine = line.toUpperCase().contains('IFSC');
      for (final code in _ifscCandidatesFromLine(line)) {
        add(code, score: onIfscLine ? 40 : 20);
      }
    }

    final bankCodes = candidates.keys
        .map((c) => c.substring(0, 4))
        .where(_isLikelyBankPrefix)
        .toSet();

    if (branchDigits != null) {
      final suffix = branchDigits.padLeft(6, '0');
      for (final bank in bankCodes) {
        add('${bank}0$suffix', score: 35);
      }
    }

    if (candidates.isEmpty) return null;

    return candidates.entries
        .map((e) => MapEntry(e.key, e.value + _ifscBonus(e.key, branchDigits)))
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  int _ifscBonus(String ifsc, String? branchDigits) {
    if (branchDigits == null) return 0;
    final suffix = branchDigits.padLeft(6, '0');
    if (ifsc.endsWith(suffix)) return 15;
    return 0;
  }

  String? _branchCodeDigits(String blob) {
    final match = RegExp(
      r'BRANCH\s*COD[E]?\D*(\d{3,6})',
      caseSensitive: false,
    ).firstMatch(blob.toUpperCase());
    return match?.group(1);
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
      final repaired = _repairIfsc(explicit.group(1)!);
      if (repaired != null) found.add(repaired);
    }

    final direct = AppRegex.ifsc.firstMatch(upper);
    if (direct != null) found.add(direct.group(0)!);

    final scanStart = upper.contains('IFSC') ? upper.indexOf('IFSC') + 4 : 0;
    final compact =
        upper.substring(scanStart).replaceAll(RegExp(r'[^A-Z0-9]'), '');

    for (var i = 0; i <= compact.length - 11; i++) {
      final repaired = _repairIfsc(compact.substring(i, i + 11));
      if (repaired != null) found.add(repaired);
    }

    return found;
  }

  bool _isAccountLabelLine(String line) {
    final upper = line.toUpperCase();
    return AppRegex.accountKeyword.hasMatch(line) ||
        RegExp(r'^ACC(OUNT|OU)', caseSensitive: false).hasMatch(upper);
  }

  bool _isLikelyBankPrefix(String prefix) {
    const blocked = {'ACCO', 'OUNT', 'IFSC', 'STAT', 'BANK', 'CUST', 'NAME'};
    return !blocked.contains(prefix);
  }

  bool _lineMayContainIfsc(String upper) {
    if (upper.contains('IFSC')) return true;
    if (RegExp(r'[A-Z]{4}0[A-Z0-9]{5}').hasMatch(upper)) return true;
    // Garbled OCR lines (e.g. `SCSBINQCE6922`) mix letters and digits.
    return RegExp(r'[A-Z]{4}').hasMatch(upper) && RegExp(r'\d').hasMatch(upper);
  }

  String? _repairIfsc(String raw) {
    if (raw.length < 11) return null;
    final normalised = TextCleaner.normaliseIfsc(raw.substring(0, 11));
    final tail = normalised.substring(5).split('').map(_ocrToDigit).join();
    final result = '${normalised.substring(0, 5)}$tail';
    return Validators.isIfscValid(result) ? result : null;
  }

  // ── Account ───────────────────────────────────────────────────────────────

  String? _extractAccountNumber(
    List<String> lines,
    String blob, {
    String? ifsc,
  }) {
    final cifNumbers = _numbersNearKeyword(lines, RegExp(r'\bCIF\b', caseSensitive: false));
    final preferred = <String>[];
    final fallback = <String>[];

    final blobAccount = RegExp(
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

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (AppRegex.accountExcludeKeyword.hasMatch(line)) continue;
      if (RegExp(r'\bCIF\b', caseSensitive: false).hasMatch(line)) continue;

      final nearKeyword = AppRegex.accountKeyword.hasMatch(line) ||
          (i > 0 && AppRegex.accountKeyword.hasMatch(lines[i - 1]));

      for (final n in _accountDigitsFromLine(line)) {
        if (!_isPlausibleAccount(n, cifNumbers: cifNumbers, ifsc: ifsc)) continue;
        (nearKeyword ? preferred : fallback).add(n);
      }
    }

    if (preferred.isNotEmpty) return _longestUnique(preferred);
    if (fallback.isNotEmpty) return _longestUnique(fallback);
    return null;
  }

  Set<String> _numbersNearKeyword(List<String> lines, RegExp keyword) {
    final numbers = <String>{};
    for (var i = 0; i < lines.length; i++) {
      if (!keyword.hasMatch(lines[i])) continue;
      numbers.addAll(_accountDigitsFromLine(lines[i]));
      if (i + 1 < lines.length &&
          !AppRegex.accountKeyword.hasMatch(lines[i + 1])) {
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

    for (final match in RegExp(r'[A-Z]?\d{9,17}').allMatches(line.toUpperCase())) {
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

  // ── Holder / bank / branch ────────────────────────────────────────────────

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
    final candidates = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.toUpperCase().contains('BRANCH')) continue;

      final match = RegExp(r'BRANCH', caseSensitive: false).firstMatch(line)!;
      final after = line.substring(match.end).replaceFirst(RegExp(r'^[:\-\s]+'), '').trim();
      final before = line.substring(0, match.start).trim();

      if (after.length > 3) candidates.add(after);
      if (before.length > 3) candidates.add('$before BRANCH');

      if (i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (next.isNotEmpty && !RegExp(r'\d').hasMatch(next)) {
          candidates.add(next);
        }
      }
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => _branchRank(b).compareTo(_branchRank(a)));
    return candidates.first;
  }

  int _branchRank(String name) {
    final upper = name.toUpperCase();
    var rank = 0;
    if (upper.contains('BRANCH')) rank += 4;
    if (name.length <= 30) rank += 3;
    if (!RegExp(r'\d').hasMatch(name)) rank += 2;
    if (upper.contains('VILL') || upper.contains(' PO ') || upper.contains('P.O')) {
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
