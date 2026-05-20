import 'dart:io';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/image_crop_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/permission_service.dart';
import '../models/card_details.dart';
import '../parsers/card_parser.dart';

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

class CardScanCropCancelledFailure extends CardScanFailure {
  const CardScanCropCancelledFailure(super.message);
}

class CardScanOcrFailure extends CardScanFailure {
  const CardScanOcrFailure(super.message);
}

class CardScanParseFailure extends CardScanFailure {
  const CardScanParseFailure(super.message);
}

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

abstract class CardScannerRepository {
  Future<CardScanResult> scan(AppImageSource source);
}

class CardScannerRepositoryImpl implements CardScannerRepository {
  CardScannerRepositoryImpl({
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

    final picked = await imageService.pickImage(source);
    if (picked == null) {
      throw const CardScanNoImageFailure('No image was selected.');
    }

    final cropped = await imageCropService.cropImage(picked, CropProfile.card);
    if (cropped == null) {
      throw const CardScanCropCancelledFailure(AppStrings.errorCropCancelled);
    }

    try {
      final ocr = await ocrService.extractText(cropped);
      final details = parser.parseCard(ocr.cleanedText);

      if (!details.hasData) {
        throw const CardScanParseFailure(
          'We could not extract any card data from the image.',
        );
      }

      return CardScanResult(
        image: cropped,
        details: details,
        rawText: ocr.cleanedText,
      );
    } on OcrException catch (e) {
      throw CardScanOcrFailure(e.message);
    }
  }
}
