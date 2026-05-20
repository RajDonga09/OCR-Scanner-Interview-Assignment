import '../constants/app_constants.dart';
import '../constants/app_regex.dart';

/// Pure validation helpers shared across features.
///
/// Validators never depend on UI / Flutter so they remain trivially testable.
class Validators {
  const Validators._();

  /// Whether [digits] could plausibly be a card number based solely on length.
  ///
  /// We accept 13–19 digits because:
  ///   * 13 → old Visa
  ///   * 15 → American Express
  ///   * 16 → Mastercard / Visa / Discover
  ///   * 19 → some Maestro cards
  static bool isCardLengthValid(String digits) {
    final length = digits.length;
    return length >= AppConstants.minCardDigits &&
        length <= AppConstants.maxCardDigits;
  }

  /// Whether [digits] could plausibly be an account number.
  static bool isAccountLengthValid(String digits) {
    final length = digits.length;
    return length >= AppConstants.minAccountDigits &&
        length <= AppConstants.maxAccountDigits;
  }

  /// Whether [value] is a properly formatted IFSC code.
  ///
  /// The official RBI pattern is `[A-Z]{4}0[A-Z0-9]{6}`. The 5th character
  /// is reserved as `0`.
  static bool isIfscValid(String? value) {
    if (value == null || value.isEmpty) return false;
    if (value.length != AppConstants.ifscLength) return false;
    return AppRegex.ifsc.hasMatch(value);
  }

  /// Whether [value] looks like an Indian mobile number, so we can exclude
  /// it from account-number candidates.
  static bool isMobileNumber(String value) =>
      AppRegex.mobileNumber.hasMatch(value);

  /// Whether [value] is a credible expiry date in `MM/YY` form.
  ///
  /// The check is intentionally light — we do not reject already-expired
  /// dates because a scanner should still surface them to the user.
  static bool isExpiryValid(String? value) {
    if (value == null || value.length != 5 || value[2] != '/') return false;
    final month = int.tryParse(value.substring(0, 2));
    final year = int.tryParse(value.substring(3, 5));
    if (month == null || year == null) return false;
    return month >= 1 && month <= 12 && year >= 0 && year <= 99;
  }
}
