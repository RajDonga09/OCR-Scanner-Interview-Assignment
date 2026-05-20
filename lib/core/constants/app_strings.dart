/// Centralised user-facing strings.
///
/// Keeping them in one file makes localisation a simple drop-in later and
/// guarantees we never duplicate strings across screens.
class AppStrings {
  const AppStrings._();

  // App
  static const String appName = 'OCR Scanner';

  // Home
  static const String homeTitle = 'OCR Scanner';
  static const String homeSubtitle =
      'Scan cards & passbooks. Extract structured data on-device.';
  static const String scanCard = 'Scan Card';
  static const String scanCardDescription =
      'Capture or pick a credit / debit card to extract the card number, holder name and expiry date.';
  static const String scanPassbook = 'Scan Passbook';
  static const String scanPassbookDescription =
      'Capture or pick a bank passbook page to extract the holder name, account number and IFSC code.';

  // Card scanner
  static const String cardScannerTitle = 'Card Scanner';
  static const String cardScannerHint =
      'Use a well-lit photo with the full card inside the frame.';
  static const String cardNumber = 'Card Number';
  static const String cardHolder = 'Card Holder';
  static const String cardExpiry = 'Valid Thru';
  static const String maskedCardNumber = 'Masked Number';
  static const String cardBrand = 'Network';
  static const String luhnValid = 'Luhn Check';
  static const String luhnPassed = 'Passed';
  static const String luhnFailed = 'Failed';

  // Passbook scanner
  static const String passbookScannerTitle = 'Passbook Scanner';
  static const String passbookScannerHint =
      'Place the page flat with the printed details visible.';
  static const String accountHolder = 'Account Holder';
  static const String accountNumber = 'Account Number';
  static const String ifsc = 'IFSC Code';
  static const String bankName = 'Bank';
  static const String branch = 'Branch';

  // Result
  static const String scanResultTitle = 'Scan Result';
  static const String rawText = 'Raw OCR Text';
  static const String extractedData = 'Extracted Data';
  static const String preview = 'Image Preview';
  static const String rescan = 'Rescan';
  static const String done = 'Done';
  static const String notDetected = 'Not detected';

  // Actions
  static const String useCamera = 'Use Camera';
  static const String useGallery = 'Use Gallery';
  static const String tryAgain = 'Try Again';
  static const String cancel = 'Cancel';

  // States
  static const String loading = 'Processing image…';
  static const String emptyTitle = 'No data yet';
  static const String emptySubtitle = 'Capture or pick an image to begin.';
  static const String errorTitle = 'Something went wrong';

  // Errors
  static const String errorCameraPermission =
      'Camera permission is required to scan. Please enable it in Settings.';
  static const String errorGalleryPermission =
      'Gallery permission is required to pick an image.';
  static const String errorNoImage = 'No image was selected.';
  static const String errorOcrFailed =
      'Unable to read text from the image. Try another photo.';
  static const String errorEmptyOcr =
      'The image did not contain any readable text.';
  static const String errorInvalidCard =
      'The detected number does not look like a valid card.';
  static const String errorInvalidIfsc =
      'The detected code does not match the IFSC format.';
  static const String errorParsing =
      'We could not extract structured data from this scan.';
}
