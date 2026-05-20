/// Pre-compiled regular expressions used by the parsers.
///
/// Keeping every regex in one place avoids subtle drift between modules and
/// makes the OCR-handling pipeline auditable in a single file.
class AppRegex {
  const AppRegex._();

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  /// Matches sequences of two or more whitespace characters.
  static final RegExp whitespace = RegExp(r'\s{2,}');

  /// Matches any character that is not allowed in a normalised OCR line.
  ///
  /// We deliberately keep letters, digits, common separators and slashes —
  /// everything else is treated as noise (stars, bullets, emojis, weird Unicode).
  static final RegExp noise = RegExp(r"[^A-Za-z0-9 /\-:.,'\n]");

  /// Used to strip everything that is not a digit.
  static final RegExp nonDigits = RegExp(r'[^0-9]');

  /// Detects a single line composed solely of digits and spacing.
  static final RegExp digitsOnlyLine = RegExp(r'^[\d\s\-]+$');

  /// Detects a "purely alphabetic" line (letters and spaces only).
  static final RegExp lettersOnlyLine = RegExp(r"^[A-Za-z .'\-]+$");

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  /// Card number with optional spaces or dashes between groups.
  ///
  /// Accepts 13–19 digit PANs (Visa-13, Amex-15, standard-16, Maestro-19).
  static final RegExp cardNumberLoose = RegExp(
    r'(?:\d[ -]?){12,18}\d',
  );

  /// Expiry MM/YY or MM-YY or MMYY anywhere in a string.
  static final RegExp expiry = RegExp(
    r'(0[1-9]|1[0-2])[ /\-]?(\d{2}|\d{4})',
  );

  // ---------------------------------------------------------------------------
  // Passbook / Banking
  // ---------------------------------------------------------------------------

  /// IFSC pattern: 4 capital letters + 0 + 6 alphanumerics.
  ///
  /// The official RBI specification reserves the 5th character as `0`, with
  /// the trailing six characters numeric or alphanumeric depending on the
  /// vintage of the branch code — we accept both for robustness.
  static final RegExp ifsc = RegExp(r'\b[A-Z]{4}0[A-Z0-9]{6}\b');

  /// Indian mobile number (10 digits starting with 6–9, optionally +91).
  static final RegExp mobileNumber = RegExp(r'(?:\+?91[- ]?)?[6-9]\d{9}');

  /// Account number candidates: 9–18 contiguous digits.
  static final RegExp accountCandidate = RegExp(r'\b\d{9,18}\b');

  /// Lines that contain a hint that we are looking at an account number.
  static final RegExp accountKeyword = RegExp(
    r'(ACCOUNT\s*(NO|NUMBER)?|A\s*/\s*C\s*(NO)?|AC\s*NO)',
    caseSensitive: false,
  );

  /// Lines that hint at the holder name.
  static final RegExp nameKeyword = RegExp(
    r"(NAME|HOLDER|MR\.|MRS\.|MS\.|SHRI|SMT\.)",
    caseSensitive: false,
  );

  /// Lines that hint at branch / address information we want to ignore for
  /// the name extraction.
  static final RegExp branchKeyword = RegExp(
    r'(BRANCH|ADDRESS|CITY|STATE|PIN|BANK)',
    caseSensitive: false,
  );

  /// Probable human name pattern — two or more capitalised tokens.
  static final RegExp humanName = RegExp(
    r"^([A-Z][A-Z'.\-]{1,}\s){1,4}[A-Z][A-Z'.\-]{1,}$",
  );
}
