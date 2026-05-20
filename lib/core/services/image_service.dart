import 'dart:io';

import 'package:image_picker/image_picker.dart' as picker;
import 'package:ocr_interview_assignment/core/core.dart';

enum AppImageSource { camera, gallery }

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
