import 'dart:io';

/// Tiny helpers around `dart:io.File` used by the OCR pipeline.
class ImageUtils {
  const ImageUtils._();

  /// Returns true when the file exists and is non-empty.
  static Future<bool> isUsable(File file) async {
    if (!await file.exists()) return false;
    final length = await file.length();
    return length > 0;
  }

  /// Returns the trailing path segment of [path] without its extension.
  static String basenameWithoutExtension(String path) {
    final segments = path.split(Platform.pathSeparator);
    final last = segments.isEmpty ? path : segments.last;
    final dot = last.lastIndexOf('.');
    return dot == -1 ? last : last.substring(0, dot);
  }
}
