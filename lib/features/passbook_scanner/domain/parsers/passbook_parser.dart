import '../../../../core/constants/app_regex.dart';
import '../../../../core/utils/parser_helper.dart';
import '../../../../core/utils/text_cleaner.dart';
import '../../../../core/utils/validators.dart';
import '../models/bank_details.dart';

/// Manually implemented parser that turns the noisy OCR output of an Indian
/// bank passbook page into a [BankDetails] value.
///
/// The parser is stateless and pure (see [CardParser] for the same rationale).
class PassbookParser {
  const PassbookParser();

  /// Parses [rawText] into a [BankDetails].
  BankDetails parsePassbook(String rawText) {
    if (rawText.isEmpty) return BankDetails.empty();

    final cleaned = TextCleaner.clean(rawText);
    final lines = TextCleaner.toLines(cleaned);
    if (lines.isEmpty) return BankDetails.empty();

    final ifsc = _extractIfsc(lines);
    final accountNumber = _extractAccountNumber(lines, ifsc: ifsc);
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

  // ---------------------------------------------------------------------------
  // IFSC
  // ---------------------------------------------------------------------------

  String? _extractIfsc(List<String> lines) {
    for (final line in lines) {
      // Normalise common OCR mistakes for the IFSC token before searching.
      final normalised = _normaliseIfscTokens(line);

      final match = AppRegex.ifsc.firstMatch(normalised);
      if (match != null) return match.group(0);
    }
    return null;
  }

  /// Locates 11-character tokens that look like IFSC candidates and runs the
  /// IFSC-specific normalisation on each one so a single misread `O` does not
  /// throw away the match.
  String _normaliseIfscTokens(String line) {
    final upper = line.toUpperCase();
    final candidates = RegExp(r'\b[A-Z0-9]{11}\b').allMatches(upper);
    if (candidates.isEmpty) return upper;

    var result = upper;
    for (final match in candidates) {
      final original = match.group(0)!;
      final normalised = TextCleaner.normaliseIfsc(original);
      if (normalised != original) {
        result = result.replaceFirst(original, normalised);
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Account number
  // ---------------------------------------------------------------------------

  String? _extractAccountNumber(List<String> lines, {String? ifsc}) {
    final preferred = <String>[];
    final fallback = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final normalised = TextCleaner.normaliseDigits(line);
      final isPreferred = AppRegex.accountKeyword.hasMatch(line);

      final candidatesForLine = <String>{};

      // Direct matches inside this line.
      for (final m in AppRegex.accountCandidate.allMatches(normalised)) {
        candidatesForLine.add(m.group(0)!);
      }

      // Sometimes "Account No." sits on its own line and the digits land on
      // the following line. Walk the next line too if we matched the keyword.
      if (isPreferred && i + 1 < lines.length) {
        final next = TextCleaner.normaliseDigits(lines[i + 1]);
        for (final m in AppRegex.accountCandidate.allMatches(next)) {
          candidatesForLine.add(m.group(0)!);
        }
      }

      for (final candidate in candidatesForLine) {
        if (!_isPlausibleAccount(candidate, ifsc: ifsc)) continue;
        (isPreferred ? preferred : fallback).add(candidate);
      }
    }

    // 1) Prefer numbers attached to an account keyword.
    if (preferred.isNotEmpty) return _pickAccountFromCandidates(preferred);

    // 2) Otherwise fall back to the longest plausible run anywhere in the doc.
    if (fallback.isNotEmpty) return _pickAccountFromCandidates(fallback);

    return null;
  }

  String _pickAccountFromCandidates(List<String> candidates) {
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  bool _isPlausibleAccount(String digits, {String? ifsc}) {
    if (!Validators.isAccountLengthValid(digits)) return false;

    // Reject mobile-number-shaped runs (10 digits starting 6-9 anywhere in
    // the candidate).
    if (digits.length == 10 && Validators.isMobileNumber(digits)) return false;

    // Reject if the digits are a sub-string of the detected IFSC. The IFSC
    // tail can be numeric and would otherwise sneak through.
    if (ifsc != null && ifsc.contains(digits)) return false;

    return true;
  }

  // ---------------------------------------------------------------------------
  // Holder name
  // ---------------------------------------------------------------------------

  String? _extractHolderName(List<String> lines) {
    // Step 1 — explicit `NAME: …` style lines win every time.
    final explicit = _extractAfterKeyword(lines, AppRegex.nameKeyword);
    if (explicit != null) return explicit;

    // Step 2 — heuristic: the holder name is usually:
    //   * the first letter-only line
    //   * that does NOT match a bank/branch keyword
    //   * and is plausibly a real name (multiple capitalised tokens).
    return ParserHelper.bestNameCandidate(
      lines,
      exclusions: <RegExp>[
        AppRegex.branchKeyword,
        RegExp(r'(STATE BANK|HDFC|ICICI|AXIS|PUNJAB|CANARA|YES BANK)',
            caseSensitive: false),
        RegExp(r'(SAVINGS|CURRENT|PASSBOOK|ACCOUNT|STATEMENT|CUSTOMER ID)',
            caseSensitive: false),
      ],
    );
  }

  String? _extractAfterKeyword(List<String> lines, RegExp keyword) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = keyword.firstMatch(line);
      if (match == null) continue;

      final remainder = line.substring(match.end).trim();
      final cleaned = remainder.replaceFirst(RegExp(r'^[:\-\s]+'), '').trim();
      if (cleaned.length >= 3 && !RegExp(r'\d').hasMatch(cleaned)) {
        return cleaned;
      }

      // If nothing useful is on the same line, look at the next one.
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

  // ---------------------------------------------------------------------------
  // Bank / branch
  // ---------------------------------------------------------------------------

  String? _extractBankName(List<String> lines) {
    final knownBanks = <RegExp>[
      RegExp(r'STATE BANK( OF INDIA)?', caseSensitive: false),
      RegExp(r'HDFC BANK', caseSensitive: false),
      RegExp(r'ICICI BANK', caseSensitive: false),
      RegExp(r'AXIS BANK', caseSensitive: false),
      RegExp(r'PUNJAB NATIONAL BANK', caseSensitive: false),
      RegExp(r'CANARA BANK', caseSensitive: false),
      RegExp(r'BANK OF (BARODA|INDIA|MAHARASHTRA)', caseSensitive: false),
      RegExp(r'KOTAK( MAHINDRA)? BANK', caseSensitive: false),
      RegExp(r'UNION BANK( OF INDIA)?', caseSensitive: false),
      RegExp(r'IDBI BANK', caseSensitive: false),
      RegExp(r'YES BANK', caseSensitive: false),
      RegExp(r'INDIAN BANK', caseSensitive: false),
    ];

    for (final line in lines) {
      for (final regex in knownBanks) {
        final match = regex.firstMatch(line);
        if (match != null) return match.group(0)!;
      }
    }

    // Generic fallback: a line ending with "BANK" that is short enough to be
    // a name rather than an address.
    for (final line in lines) {
      if (RegExp(r'BANK\b', caseSensitive: false).hasMatch(line) &&
          line.length < 40) {
        return line.trim();
      }
    }
    return null;
  }

  String? _extractBranch(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = RegExp(r'BRANCH', caseSensitive: false).firstMatch(line);
      if (match == null) continue;

      final remainder = line.substring(match.end).trim();
      final cleaned = remainder.replaceFirst(RegExp(r'^[:\-\s]+'), '').trim();
      if (cleaned.isNotEmpty) return cleaned;

      if (i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (next.isNotEmpty && !RegExp(r'\d').hasMatch(next)) return next;
      }
    }
    return null;
  }
}
