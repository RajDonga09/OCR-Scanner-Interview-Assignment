import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../domain/models/bank_details.dart';

class PassbookVisual extends StatelessWidget {
  const PassbookVisual({super.key, required this.details});

  final BankDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.passbookGradientStart,
            AppColors.passbookGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.passbookGradientStart.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded,
                  color: AppColors.textOnPrimary),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: AppText(
                  details.bankName ?? 'Bank Passbook',
                  variant: AppTextVariant.bodyStrong,
                  color: AppColors.textOnPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space20),
          AppText(
            AppStrings.accountHolder.toUpperCase(),
            variant: AppTextVariant.label,
            color: AppColors.textOnPrimary,
          ),
          const SizedBox(height: 2),
          AppText(
            (details.accountHolder ?? AppStrings.notDetected).toUpperCase(),
            variant: AppTextVariant.subtitle,
            color: AppColors.textOnPrimary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.space16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.accountNumber.toUpperCase(),
                      variant: AppTextVariant.label,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      details.accountNumber ?? AppStrings.notDetected,
                      variant: AppTextVariant.bodyStrong,
                      color: AppColors.textOnPrimary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    AppStrings.ifsc.toUpperCase(),
                    variant: AppTextVariant.label,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    details.ifsc ?? AppStrings.notDetected,
                    variant: AppTextVariant.bodyStrong,
                    color: AppColors.textOnPrimary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
