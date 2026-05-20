import 'package:ocr_interview_assignment/dependency.dart';

/// Luhn (mod-10) check for card numbers.
class LuhnValidator {
  const LuhnValidator();

  bool isValidCard(String cardNumber) {
    final digits = ParserHelper.digitsOnly(cardNumber);
    if (!Validators.isCardLengthValid(digits)) return false;

    final reversed = digits.split('').reversed.toList(growable: false);
    var sum = 0;

    for (var index = 0; index < reversed.length; index++) {
      var value = int.parse(reversed[index]);

      // Double every second digit from the right.
      if (index.isOdd) {
        value *= 2;
        if (value > 9) value -= 9;
      }

      sum += value;
    }

    return sum % 10 == 0;
  }
}
