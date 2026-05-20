import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import 'app_text.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.image_search_rounded,
    this.action,
  });

  final String? title;
  final String? message;
  final IconData icon;
  final Widget? action;

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
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconXl,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            AppText(
              title ?? AppStrings.emptyTitle,
              variant: AppTextVariant.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            AppText(
              message ?? AppStrings.emptySubtitle,
              variant: AppTextVariant.body,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppDimensions.space20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
