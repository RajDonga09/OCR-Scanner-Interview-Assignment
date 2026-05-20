import 'dart:io';

import '../../../../core/services/image_service.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/permission_service.dart';
import '../models/card_details.dart';
import '../parsers/card_parser.dart';

/// Failure reasons that the repository can surface.
///
/// Using a sealed type rather than raw exceptions keeps the cubit state
/// machine declarative.
sealed class CardScanFailure implements Exception {
  const CardScanFailure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class CardScanPermissionFailure extends CardScanFailure {
  const CardScanPermissionFailure(super.message);
}

class CardScanNoImageFailure extends CardScanFailure {
  const CardScanNoImageFailure(super.message);
}

class CardScanOcrFailure extends CardScanFailure {
  const CardScanOcrFailure(super.message);
}

class CardScanParseFailure extends CardScanFailure {
  const CardScanParseFailure(super.message);
}

/// Output of a successful scan: the image, the extracted details and the
/// raw cleaned text (kept so the UI can display it for debugging).
class CardScanResult {
  const CardScanResult({
    required this.image,
    required this.details,
    required this.rawText,
  });

  final File image;
  final CardDetails details;
  final String rawText;
}

/// Repository abstraction used by the cubit.
abstract class CardScannerRepository {
  /// Picks a new image and returns the parsed card details.
  Future<CardScanResult> scan(AppImageSource source);
}

class CardScannerRepositoryImpl implements CardScannerRepository {
  CardScannerRepositoryImpl({
    required this.imageService,
    required this.ocrService,
    required this.permissionService,
    required this.parser,
  });

  final ImageService imageService;
  final OcrService ocrService;
  final PermissionService permissionService;
  final CardParser parser;

  @override
  Future<CardScanResult> scan(AppImageSource source) async {
    final hasPermission = source == AppImageSource.camera
        ? await permissionService.requestCamera()
        : await permissionService.requestGallery();
    if (!hasPermission) {
      throw const CardScanPermissionFailure(
        'Permission denied. Enable access from system settings.',
      );
    }

    final File? image = await imageService.pickImage(source);
    if (image == null) {
      throw const CardScanNoImageFailure('No image was selected.');
    }

    try {
      final ocr = await ocrService.extractText(image);
      final details = parser.parseCard(ocr.cleanedText);

      if (!details.hasData) {
        throw const CardScanParseFailure(
          'We could not extract any card data from the image.',
        );
      }

      return CardScanResult(
        image: image,
        details: details,
        rawText: ocr.cleanedText,
      );
    } on OcrException catch (e) {
      throw CardScanOcrFailure(e.message);
    }
  }
}
