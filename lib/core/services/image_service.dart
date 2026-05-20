import 'dart:io';

import 'package:image_picker/image_picker.dart' as picker;

import '../constants/app_constants.dart';

/// Source of an image used by the OCR pipeline.
///
/// We declare our own enum and translate to the plugin enum inside the
/// implementation so feature code is not coupled to `image_picker`.
enum AppImageSource { camera, gallery }

/// Abstracts away the underlying image-picker so the cubits can be tested
/// without binding to the real plugin.
abstract class ImageService {
  Future<File?> pickImage(AppImageSource source);
}

class ImageServiceImpl implements ImageService {
  ImageServiceImpl({picker.ImagePicker? imagePicker})
      : _picker = imagePicker ?? picker.ImagePicker();

  final picker.ImagePicker _picker;

  @override
  Future<File?> pickImage(AppImageSource source) async {
    final result = await _picker.pickImage(
      source: source == AppImageSource.camera
          ? picker.ImageSource.camera
          : picker.ImageSource.gallery,
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      imageQuality: AppConstants.imagePickerQuality,
    );
    if (result == null) return null;
    return File(result.path);
  }
}
