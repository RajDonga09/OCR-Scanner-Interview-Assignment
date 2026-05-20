import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = _buildContent();
    final isDisabled = onPressed == null || isLoading;

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
          ),
          onPressed: isDisabled ? null : onPressed,
          child: child,
        ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.textOnPrimary,
        ),
      );
    }
    if (icon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconMd),
        const SizedBox(width: AppDimensions.space8),
        Text(label),
      ],
    );
  }
}
