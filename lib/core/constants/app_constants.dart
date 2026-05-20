/// Numeric / behavioural constants used by the OCR pipeline.
class AppConstants {
  const AppConstants._();

  // OCR / parsing
  static const int minCardDigits = 13;
  static const int maxCardDigits = 19;
  static const int minAccountDigits = 9;
  static const int maxAccountDigits = 18;
  static const int ifscLength = 11;

  // Image capture
  static const int maxImageWidth = 1600;
  static const int imagePickerQuality = 92;

  // UI
  static const int rawTextPreviewLines = 12;
}
