import '../constants/app_constants.dart';
import '../constants/app_regex.dart';

class Validators {
  const Validators._();

  static bool isCardLengthValid(String digits) {
    final length = digits.length;
    return length >= AppConstants.minCardDigits &&
        length <= AppConstants.maxCardDigits;
  }

  static bool isAccountLengthValid(String digits) {
    final length = digits.length;
    return length >= AppConstants.minAccountDigits &&
        length <= AppConstants.maxAccountDigits;
  }

  static bool isIfscValid(String? value) {
    if (value == null || value.isEmpty) return false;
    if (value.length != AppConstants.ifscLength) return false;
    return AppRegex.ifsc.hasMatch(value);
  }

  static bool isMobileNumber(String value) =>
      AppRegex.mobileNumber.hasMatch(value);

  static bool isExpiryValid(String? value) {
    if (value == null || value.length != 5 || value[2] != '/') return false;
    final month = int.tryParse(value.substring(0, 2));
    final year = int.tryParse(value.substring(3, 5));
    if (month == null || year == null) return false;
    return month >= 1 && month <= 12 && year >= 0 && year <= 99;
  }
}
