import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr_interview_assignment/core/core.dart';

class OcrResult extends Equatable {
  const OcrResult({
    required this.rawText,
    required this.cleanedText,
    required this.lines,
  });

  final String rawText;
  final String cleanedText;
  final List<String> lines;

  bool get isEmpty => cleanedText.isEmpty;

  @override
  List<Object?> get props => [rawText, cleanedText, lines];
}

sealed class OcrException implements Exception {
  const OcrException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class OcrEmptyException extends OcrException {
  const OcrEmptyException(super.message);
}

class OcrFailureException extends OcrException {
  const OcrFailureException(super.message, {this.cause});

  final Object? cause;
}

abstract class OcrService {
  Future<OcrResult> extractText(File image);

  Future<void> dispose();
}

class MlKitOcrService implements OcrService {
  MlKitOcrService({TextRecognizer? recognizer})
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<OcrResult> extractText(File image) async {
    try {
      if (!await image.exists()) {
        throw const OcrFailureException('Image file does not exist.');
      }

      final input = InputImage.fromFile(image);
      final recognised = await _recognizer.processImage(input);
      final raw = recognised.text;
      final cleaned = TextCleaner.clean(raw);

      if (cleaned.isEmpty) {
        throw const OcrEmptyException(
          'OCR produced no usable text. Try a clearer photo.',
        );
      }

      return OcrResult(
        rawText: raw,
        cleanedText: cleaned,
        lines: TextCleaner.toLines(cleaned),
      );
    } on OcrException {
      rethrow;
    } catch (e, stack) {
      AppLogger.error('OCR extraction failed', error: e, stackTrace: stack);
      throw OcrFailureException(
        'Unable to read text from the image.',
        cause: e,
      );
    }
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
