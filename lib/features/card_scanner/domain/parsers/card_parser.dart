import '../../../../core/constants/app_regex.dart';
import '../../../../core/utils/parser_helper.dart';
import '../../../../core/utils/text_cleaner.dart';
import '../../../../core/utils/validators.dart';
import '../models/card_details.dart';
import 'luhn_validator.dart';

/// Manually implemented parser that extracts a [CardDetails] from raw OCR
/// text.
///
/// The parser is deliberately **stateless** and **pure**: feeding the same
/// input always yields the same output. This makes unit testing trivial
/// (see `test/features/card_scanner/card_parser_test.dart`).
class CardParser {
  const CardParser({this.luhnValidator = const LuhnValidator()});

  final LuhnValidator luhnValidator;

  /// Parses [rawText] (typically the output of [TextCleaner.clean]).
  ///
  /// The function is designed to *degrade gracefully* — even if it cannot
  /// extract a field it will still return a [CardDetails] populated with
  /// whatever it could find.
  CardDetails parseCard(String rawText) {
    if (rawText.isEmpty) return CardDetails.empty();

    final cleaned = TextCleaner.clean(rawText);
    final lines = TextCleaner.toLines(cleaned);
    if (lines.isEmpty) return CardDetails.empty();

    final cardNumber = _extractCardNumber(lines);
    final expiry = _extractExpiry(lines);
    final holder = _extractHolderName(lines);

    String? maskedNumber;
    var isLuhnValid = false;
    var brand = CardBrand.unknown;
    if (cardNumber != null) {
      maskedNumber = ParserHelper.maskCardNumber(cardNumber);
      isLuhnValid = luhnValidator.isValidCard(cardNumber);
      brand = _detectBrand(cardNumber);
    }

    return CardDetails(
      cardNumber: cardNumber,
      maskedNumber: maskedNumber,
      holderName: holder,
      expiry: expiry,
      brand: brand,
      isLuhnValid: isLuhnValid,
    );
  }

  // ---------------------------------------------------------------------------
  // Card number
  // ---------------------------------------------------------------------------

  String? _extractCardNumber(List<String> lines) {
    // Step 1 — gather every plausible candidate from every line.
    final candidates = <String>{};

    for (final line in lines) {
      // OCR often confuses letters and digits in numeric lines, so apply
      // the digit-friendly normalisation before extracting candidates.
      final normalised = TextCleaner.normaliseDigits(line);

      for (final match in AppRegex.cardNumberLoose.allMatches(normalised)) {
        final digits = ParserHelper.digitsOnly(match.group(0)!);
        if (Validators.isCardLengthValid(digits)) candidates.add(digits);
      }

      // Some scans break the PAN across multiple short numeric tokens. Try
      // joining all numeric tokens of the line into a single candidate too.
      final joined = ParserHelper.digitsOnly(normalised);
      if (Validators.isCardLengthValid(joined)) candidates.add(joined);
    }

    if (candidates.isEmpty) return null;

    // Step 2 — prefer the candidate that passes the Luhn check.
    final luhnValid = candidates.where(luhnValidator.isValidCard).toList();
    if (luhnValid.isNotEmpty) {
      // Among Luhn-valid candidates, pick the longest (handles 19-digit cards
      // that contain a Luhn-valid 16-digit subsequence).
      luhnValid.sort((a, b) => b.length.compareTo(a.length));
      return luhnValid.first;
    }

    // Step 3 — fall back to the longest candidate.
    final ordered = candidates.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return ordered.first;
  }

  // ---------------------------------------------------------------------------
  // Expiry
  // ---------------------------------------------------------------------------

  String? _extractExpiry(List<String> lines) {
    String? fallback;

    for (final line in lines) {
      final upper = line.toUpperCase();

      // Lines that explicitly mention VALID THRU / EXP get priority.
      final isExpiryLine = upper.contains('VALID') ||
          upper.contains('THRU') ||
          upper.contains('EXP');

      final match = AppRegex.expiry.firstMatch(line);
      if (match == null) continue;

      final monthStr = match.group(1)!;
      var yearStr = match.group(2)!;

      // Reject if the candidate is actually part of a longer digit run –
      // protects against picking up the middle of a card number such as
      // `4111 1125 2222 …` where `12/52` could otherwise match.
      if (!_looksLikeStandaloneExpiry(line, match)) continue;

      if (yearStr.length == 4) yearStr = yearStr.substring(2);
      final formatted = '$monthStr/$yearStr';
      if (!Validators.isExpiryValid(formatted)) continue;

      if (isExpiryLine) return formatted;

      // Otherwise keep looking — but remember the candidate to use as a
      // fallback if no explicit expiry line is found.
      fallback ??= formatted;
    }
    return fallback;
  }

  bool _looksLikeStandaloneExpiry(String line, RegExpMatch match) {
    final before = match.start == 0 ? '' : line[match.start - 1];
    final after = match.end == line.length ? '' : line[match.end];
    final boundedBefore = before.isEmpty || !RegExp(r'\d').hasMatch(before);
    final boundedAfter = after.isEmpty || !RegExp(r'\d').hasMatch(after);
    return boundedBefore && boundedAfter;
  }

  // ---------------------------------------------------------------------------
  // Holder name
  // ---------------------------------------------------------------------------

  static final _holderExclusions = <RegExp>[
    RegExp(r'\bVISA\b', caseSensitive: false),
    RegExp(r'\bMASTER\s*CARD\b', caseSensitive: false),
    RegExp(r'\bMASTERCARD\b', caseSensitive: false),
    RegExp(r'\bAMERICAN\s*EXPRESS\b', caseSensitive: false),
    RegExp(r'\bAMEX\b', caseSensitive: false),
    RegExp(r'\bRUPAY\b', caseSensitive: false),
    RegExp(r'\bDISCOVER\b', caseSensitive: false),
    RegExp(r'\bVALID\b', caseSensitive: false),
    RegExp(r'\bTHRU\b', caseSensitive: false),
    RegExp(r'\bEXPIR', caseSensitive: false),
    RegExp(r'\bAUTHORIZED\b', caseSensitive: false),
    RegExp(r'\bDEBIT\b', caseSensitive: false),
    RegExp(r'\bCREDIT\b', caseSensitive: false),
    RegExp(r'\bBANK\b', caseSensitive: false),
    RegExp(r'\bCARD\b', caseSensitive: false),
    RegExp(r'\bPLATINUM\b', caseSensitive: false),
    RegExp(r'\bGOLD\b', caseSensitive: false),
    RegExp(r'\bSIGNATURE\b', caseSensitive: false),
    RegExp(r'\bINTERNATIONAL\b', caseSensitive: false),
  ];

  String? _extractHolderName(List<String> lines) {
    return ParserHelper.bestNameCandidate(
      lines,
      exclusions: _holderExclusions,
    );
  }

  // ---------------------------------------------------------------------------
  // Brand detection
  // ---------------------------------------------------------------------------

  CardBrand _detectBrand(String digits) {
    if (digits.startsWith('4')) return CardBrand.visa;
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(digits)) {
      return CardBrand.masterCard;
    }
    if (RegExp(r'^3[47]').hasMatch(digits)) return CardBrand.amex;
    if (RegExp(r'^(60|65|81|82)').hasMatch(digits)) return CardBrand.rupay;
    if (digits.startsWith('6011') || digits.startsWith('65')) {
      return CardBrand.discover;
    }
    return CardBrand.unknown;
  }
}
