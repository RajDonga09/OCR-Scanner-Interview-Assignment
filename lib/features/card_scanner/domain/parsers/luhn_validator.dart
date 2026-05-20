import '../../../../core/utils/parser_helper.dart';
import '../../../../core/utils/validators.dart';

/// Manual implementation of the **Luhn check** used by every modern card
/// network to detect simple transcription errors.
///
/// Algorithm (also called the *modulus 10* algorithm):
///
///   1. Strip everything that is not a digit and reverse the resulting
///      string so the right-most digit becomes index `0`. The right-most
///      digit is the *check digit*.
///
///   2. Walk the reversed digits from left to right. Every digit at an
///      **odd** index (index 1, 3, 5, …) – i.e. every *second* digit
///      from the right – is doubled.
///
///   3. If the doubled value is greater than `9` subtract `9`. This is the
///      common short-cut equivalent to summing the decimal digits of the
///      doubled value (e.g. `2 × 7 = 14` → `1 + 4 = 5` ≡ `14 - 9 = 5`).
///
///   4. Add all (possibly doubled / corrected) digits together.
///
///   5. The card number is valid when the total sum is divisible by `10`.
///
/// We also reject numbers whose length is outside the accepted PAN range
/// because a 4-digit string can technically satisfy the modular condition
/// without being a card number.
class LuhnValidator {
  const LuhnValidator();

  /// Returns true when [cardNumber] is a syntactically valid PAN.
  ///
  /// `cardNumber` may contain spaces, dashes or arbitrary OCR noise — only
  /// the digits are considered.
  bool isValidCard(String cardNumber) {
    final digits = ParserHelper.digitsOnly(cardNumber);

    // Step 0 — reject obviously bogus lengths up-front.
    if (!Validators.isCardLengthValid(digits)) return false;

    // Step 1 — reverse the digits.
    final reversed = digits.split('').reversed.toList(growable: false);

    var sum = 0;
    for (var index = 0; index < reversed.length; index++) {
      // Each character is guaranteed to be a digit because of `digitsOnly`.
      var value = int.parse(reversed[index]);

      // Step 2 — double every second digit from the right.
      if (index.isOdd) {
        value *= 2;

        // Step 3 — collapse two-digit results back to one digit.
        if (value > 9) value -= 9;
      }

      // Step 4 — accumulate.
      sum += value;
    }

    // Step 5 — modulus-10 check.
    return sum % 10 == 0;
  }
}
