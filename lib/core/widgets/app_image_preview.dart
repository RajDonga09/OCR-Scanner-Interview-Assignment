import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_text.dart';

class AppImagePreview extends StatelessWidget {
  const AppImagePreview({
    super.key,
    required this.file,
    this.height = AppDimensions.imagePreviewHeight,
    this.placeholderLabel,
  });

  final File? file;
  final double height;
  final String? placeholderLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: file == null ? _buildPlaceholder() : _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    return Image.file(
      file!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildPlaceholder(error: true),
    );
  }

  Widget _buildPlaceholder({bool error = false}) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error ? Icons.broken_image_rounded : Icons.image_outlined,
              color: AppColors.textMuted,
              size: AppDimensions.iconLg,
            ),
            const SizedBox(height: AppDimensions.space8),
            AppText(
              placeholderLabel ?? 'No image',
              variant: AppTextVariant.caption,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
