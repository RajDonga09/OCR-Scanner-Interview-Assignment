import '../../../../core/constants/app_regex.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/parser_helper.dart';
import '../../../../core/utils/text_cleaner.dart';
import '../../../../core/utils/validators.dart';
import '../models/card_details.dart';
import 'luhn_validator.dart';

class CardParser {
  const CardParser({this.luhnValidator = const LuhnValidator()});

  final LuhnValidator luhnValidator;

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

  String? _extractCardNumber(List<String> lines) {
    final candidates = <String>{};

    for (final line in lines) {
      final normalised = TextCleaner.normaliseDigits(line);

      for (final match in AppRegex.cardNumberLoose.allMatches(normalised)) {
        final digits = ParserHelper.digitsOnly(match.group(0)!);
        if (Validators.isCardLengthValid(digits)) candidates.add(digits);
      }

      final joined = ParserHelper.digitsOnly(normalised);
      if (Validators.isCardLengthValid(joined)) candidates.add(joined);
    }

    if (candidates.isEmpty) return null;

    final luhnValid = candidates.where(luhnValidator.isValidCard).toList();
    if (luhnValid.isNotEmpty) {
      luhnValid.sort((a, b) => b.length.compareTo(a.length));
      return luhnValid.first;
    }

    final ordered = candidates.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return ordered.first;
  }

  String? _extractExpiry(List<String> lines) {
    String? fallback;

    for (final line in lines) {
      final upper = line.toUpperCase();
      final isExpiryLine = upper.contains('VALID') ||
          upper.contains('THRU') ||
          upper.contains('EXP');

      final match = AppRegex.expiry.firstMatch(line);
      if (match == null) continue;

      final monthStr = match.group(1)!;
      var yearStr = match.group(2)!;

      if (!_looksLikeStandaloneExpiry(line, match)) continue;

      if (yearStr.length == 4) yearStr = yearStr.substring(2);
      final formatted = '$monthStr/$yearStr';
      if (!Validators.isExpiryValid(formatted)) continue;

      if (isExpiryLine) return formatted;
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
    RegExp(r'\bSMART\b', caseSensitive: false),
    RegExp(r'\bCHIP\b', caseSensitive: false),
    RegExp(r'\bCHIPS\b', caseSensitive: false),
  ];

  static const _holderLabelWords = <String>{
    'DEBIT',
    'CREDIT',
    'CARD',
    'VALID',
    'THRU',
    'FROM',
    'THROUGH',
    'MEMBER',
    'SINCE',
    'BANK',
    'VISA',
    'MASTERCARD',
    'AMEX',
    'RUPAY',
    'DISCOVER',
    'PLATINUM',
    'GOLD',
    'SIGNATURE',
    'INTERNATIONAL',
    'AUTHORIZED',
    'SMART',
    'CHIP',
    'CHIPS',
  };

  String? _extractHolderName(List<String> lines) {
    final fromBottom = _extractHolderFromBottom(lines);
    if (fromBottom != null) return fromBottom;

    return ParserHelper.bestNameCandidate(
      lines,
      exclusions: _holderExclusions,
    );
  }

  /// Card holder names sit at the bottom; scan upward and merge split lines.
  String? _extractHolderFromBottom(List<String> lines) {
    final parts = <String>[];

    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        if (parts.isNotEmpty) break;
        continue;
      }

      if (RegExp(r'\d').hasMatch(line)) {
        if (parts.isNotEmpty) break;
        continue;
      }

      if (_holderExclusions.any((regex) => regex.hasMatch(line))) {
        if (parts.isNotEmpty) break;
        continue;
      }

      if (!_isHolderNameToken(line)) {
        if (parts.isNotEmpty) break;
        continue;
      }

      parts.insert(0, line);
      if (parts.length >= 4) break;
    }

    if (parts.isEmpty) return null;

    final name = parts.join(' ').collapseWhitespace();
    return _isPlausibleHolderName(name) ? name : null;
  }

  bool _isHolderNameToken(String line) {
    final letters = line.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.length < 2) return false;

    final tokens = line.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    for (final token in tokens) {
      if (_holderLabelWords.contains(token.toUpperCase())) return false;
    }
    return true;
  }

  bool _isPlausibleHolderName(String name) {
    final tokens = name
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return false;

    if (tokens.length >= 2) {
      return tokens.every((t) => !_holderLabelWords.contains(t.toUpperCase()));
    }

    final word = tokens.single.toUpperCase();
    if (_holderLabelWords.contains(word)) return false;
    return tokens.single.length >= 5;
  }

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
