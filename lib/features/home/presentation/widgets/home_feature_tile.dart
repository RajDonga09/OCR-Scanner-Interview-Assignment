import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';

class HomeFeatureTile extends StatelessWidget {
  const HomeFeatureTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        padding: const EdgeInsets.all(AppDimensions.space20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.textOnPrimary,
                size: AppDimensions.iconLg,
              ),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.subtitle,
                    color: AppColors.textOnPrimary,
                  ),
                  AppSpacing.v4,
                  AppText(
                    description,
                    variant: AppTextVariant.caption,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
