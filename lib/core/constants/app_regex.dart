class AppRegex {
  const AppRegex._();

  static final RegExp whitespace = RegExp(r'\s{2,}');
  static final RegExp noise = RegExp(r"[^A-Za-z0-9 /\-:.,'\n]");
  static final RegExp nonDigits = RegExp(r'[^0-9]');
  static final RegExp digitsOnlyLine = RegExp(r'^[\d\s\-]+$');
  static final RegExp lettersOnlyLine = RegExp(r"^[A-Za-z .'\-]+$");

  static final RegExp cardNumberLoose = RegExp(r'(?:\d[ -]?){12,18}\d');
  static final RegExp expiry = RegExp(
    r'(0[1-9]|1[0-2])[ /\-]?(\d{2}|\d{4})',
  );

  static final RegExp ifsc = RegExp(r'\b[A-Z]{4}0[A-Z0-9]{6}\b');
  static final RegExp mobileNumber = RegExp(r'(?:\+?91[- ]?)?[6-9]\d{9}');
  static final RegExp accountCandidate = RegExp(r'\b\d{9,18}\b');
  static final RegExp accountKeyword = RegExp(
    r'(ACCOUNT\s*(NO|NUMBER)?|A\s*/\s*C\s*(NO)?|AC\s*NO)',
    caseSensitive: false,
  );
  static final RegExp accountExcludeKeyword = RegExp(
    r'\b(CIF|MICR|NOM|PIN|BRANCH\s*CODE|PHONE|EMAIL)\b',
    caseSensitive: false,
  );
  static final RegExp nameKeyword = RegExp(
    r'(CUSTOMER\s*NAME|ACCOUNT\s*HOLDER|HOLDER\s*NAME|NAME|HOLDER|MR\.|MRS\.|MS\.|SHRI|SMT\.)',
    caseSensitive: false,
  );
  static final RegExp guardianKeyword = RegExp(
    r'S\s*/\s*D\s*/\s*W',
    caseSensitive: false,
  );
  static final RegExp branchKeyword = RegExp(
    r'(BRANCH|ADDRESS|CITY|STATE|PIN|BANK)',
    caseSensitive: false,
  );
  static final RegExp humanName = RegExp(
    r"^([A-Z][A-Z'.\-]{1,}\s){1,4}[A-Z][A-Z'.\-]{1,}$",
  );
}
