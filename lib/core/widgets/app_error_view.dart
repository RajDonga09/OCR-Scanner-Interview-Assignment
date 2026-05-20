import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';
import 'app_text.dart';

/// Reusable empty-state container for error situations.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconXl,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            AppText(
              title ?? AppStrings.errorTitle,
              variant: AppTextVariant.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            AppText(
              message,
              variant: AppTextVariant.body,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space20),
              AppButton(
                label: AppStrings.tryAgain,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                fullWidth: false,
                variant: AppButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
