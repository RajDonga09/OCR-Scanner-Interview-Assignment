import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

enum CropProfile { card, passbook }

abstract class ImageCropService {
  Future<File?> cropImage(File source, CropProfile profile);
}

class ImageCropServiceImpl implements ImageCropService {
  const ImageCropServiceImpl();

  @override
  Future<File?> cropImage(File source, CropProfile profile) {
    return profile == CropProfile.card
        ? _cropCard(source)
        : _cropPassbook(source);
  }

  Future<File?> _cropCard(File source) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: source.path,
      aspectRatio: const CropAspectRatio(
        ratioX: AppConstants.cardAspectRatioX,
        ratioY: AppConstants.cardAspectRatioY,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppStrings.cropCardTitle,
          toolbarColor: const Color(0xFF1F6FEB),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF1F6FEB),
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: AppStrings.cropCardTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  /// Passbook pages are landscape and vary by bank — free crop fits all layouts.
  Future<File?> _cropPassbook(File source) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: source.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppStrings.cropPassbookTitle,
          toolbarColor: const Color(0xFF14B8A6),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF14B8A6),
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: AppStrings.cropPassbookTitle,
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPickerButtonHidden: false,
        ),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }
}
