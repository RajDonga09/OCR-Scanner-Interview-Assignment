import 'package:flutter/material.dart';
import 'package:ocr_interview_assignment/core/core.dart';

enum AppTextVariant {
  display,
  title,
  subtitle,
  body,
  bodyStrong,
  caption,
  label,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _styleFor(
        variant,
      ).copyWith(color: color ?? _defaultColor(variant)),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  TextStyle _styleFor(AppTextVariant variant) {
    switch (variant) {
      case AppTextVariant.display:
        return const TextStyle(
          fontSize: AppDimensions.fontXxl,
          fontWeight: FontWeight.w700,
          height: 1.15,
          letterSpacing: -0.5,
        );
      case AppTextVariant.title:
        return const TextStyle(
          fontSize: AppDimensions.fontXl,
          fontWeight: FontWeight.w700,
          height: 1.2,
        );
      case AppTextVariant.subtitle:
        return const TextStyle(
          fontSize: AppDimensions.fontLg,
          fontWeight: FontWeight.w600,
          height: 1.3,
        );
      case AppTextVariant.body:
        return const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w400,
          height: 1.4,
        );
      case AppTextVariant.bodyStrong:
        return const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w600,
          height: 1.4,
        );
      case AppTextVariant.caption:
        return const TextStyle(
          fontSize: AppDimensions.fontSm,
          fontWeight: FontWeight.w400,
          height: 1.3,
        );
      case AppTextVariant.label:
        return const TextStyle(
          fontSize: AppDimensions.fontXs,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        );
    }
  }

  Color _defaultColor(AppTextVariant variant) {
    switch (variant) {
      case AppTextVariant.display:
      case AppTextVariant.title:
      case AppTextVariant.subtitle:
      case AppTextVariant.bodyStrong:
        return AppColors.textPrimary;
      case AppTextVariant.body:
        return AppColors.textPrimary;
      case AppTextVariant.caption:
        return AppColors.textSecondary;
      case AppTextVariant.label:
        return AppColors.textMuted;
    }
  }
}
