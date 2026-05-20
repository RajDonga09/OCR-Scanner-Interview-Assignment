import 'dart:io';

import '../../../../core/services/image_service.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/permission_service.dart';
import '../models/bank_details.dart';
import '../parsers/passbook_parser.dart';

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
    required this.ocrService,
    required this.permissionService,
    required this.parser,
  });

  final ImageService imageService;
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

    final File? image = await imageService.pickImage(source);
    if (image == null) {
      throw const PassbookScanNoImageFailure('No image was selected.');
    }

    try {
      final ocr = await ocrService.extractText(image);
      final details = parser.parsePassbook(ocr.cleanedText);

      if (!details.hasData) {
        throw const PassbookScanParseFailure(
          'We could not extract any passbook data from the image.',
        );
      }

      return PassbookScanResult(
        image: image,
        details: details,
        rawText: ocr.cleanedText,
      );
    } on OcrException catch (e) {
      throw PassbookScanOcrFailure(e.message);
    }
  }
}
