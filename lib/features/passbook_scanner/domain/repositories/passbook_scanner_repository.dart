import 'package:ocr_interview_assignment/dependency.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/passbook_scanner.dart';

sealed class PassbookScanFailure implements Exception {
  const PassbookScanFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class PassbookScanPermissionFailure extends PassbookScanFailure {
  const PassbookScanPermissionFailure(super.message);
}

class PassbookScanNoImageFailure extends PassbookScanFailure {
  const PassbookScanNoImageFailure(super.message);
}

class PassbookScanCropCancelledFailure extends PassbookScanFailure {
  const PassbookScanCropCancelledFailure(super.message);
}

class PassbookScanOcrFailure extends PassbookScanFailure {
  const PassbookScanOcrFailure(super.message);
}

class PassbookScanParseFailure extends PassbookScanFailure {
  const PassbookScanParseFailure(super.message);
}

class PassbookScanResult {
  const PassbookScanResult({
    required this.image,
    required this.details,
    required this.rawText,
  });

  final File image;
  final BankDetails details;
  final String rawText;
}

abstract class PassbookScannerRepository {
  Future<PassbookScanResult> scan(AppImageSource source);
}

class PassbookScannerRepositoryImpl implements PassbookScannerRepository {
  PassbookScannerRepositoryImpl({
    required this.imageService,
    required this.imageCropService,
    required this.ocrService,
    required this.permissionService,
    required this.parser,
  });

  final ImageService imageService;
  final ImageCropService imageCropService;
  final OcrService ocrService;
  final PermissionService permissionService;
  final PassbookParser parser;

  @override
  Future<PassbookScanResult> scan(AppImageSource source) async {
    final hasPermission = source == AppImageSource.camera
        ? await permissionService.requestCamera()
        : await permissionService.requestGallery();
    if (!hasPermission) {
      throw const PassbookScanPermissionFailure(
        'Permission denied. Enable access from system settings.',
      );
    }

    final picked = await imageService.pickImage(source);
    if (picked == null) {
      throw const PassbookScanNoImageFailure('No image was selected.');
    }

    final cropped = await imageCropService.cropImage(
      picked,
      CropProfile.passbook,
    );
    if (cropped == null) {
      throw const PassbookScanCropCancelledFailure(
        AppStrings.errorCropCancelled,
      );
    }

    try {
      final ocr = await ocrService.extractText(cropped);
      final details = parser.parsePassbook(ocr.cleanedText);

      if (!details.hasData) {
        throw const PassbookScanParseFailure(
          'We could not extract any passbook data from the image.',
        );
      }

      return PassbookScanResult(
        image: cropped,
        details: details,
        rawText: ocr.cleanedText,
      );
    } on OcrException catch (e) {
      throw PassbookScanOcrFailure(e.message);
    }
  }
}
