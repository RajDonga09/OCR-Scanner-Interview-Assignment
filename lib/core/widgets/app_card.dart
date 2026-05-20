import 'package:flutter/material.dart';
import 'package:ocr_interview_assignment/core/core.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.space16),
    this.margin = EdgeInsets.zero,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusLg);
    return Padding(
      padding: margin,
      child: Material(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor ?? AppColors.divider),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
