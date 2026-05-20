import 'package:ocr_interview_assignment/dependency.dart';
import 'package:ocr_interview_assignment/features/card_scanner/card_scanner.dart';

class CardVisual extends StatelessWidget {
  const CardVisual({super.key, required this.details});

  final CardDetails details;

  @override
  Widget build(BuildContext context) {
    final number = details.maskedNumber ?? AppStrings.notDetected;
    final holder = details.holderName ?? AppStrings.notDetected;
    final expiry = details.expiry ?? '— — / — —';

    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGradientStart.withValues(alpha: 0.25),
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
                const Icon(
                  Icons.contactless_rounded,
                  color: AppColors.textOnPrimary,
                ),
                const Spacer(),
                AppText(
                  details.brand.displayName.toUpperCase(),
                  variant: AppTextVariant.label,
                  color: AppColors.textOnPrimary,
                ),
              ],
            ),
            const Spacer(),
            AppText(
              number,
              variant: AppTextVariant.subtitle,
              color: AppColors.textOnPrimary,
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        AppStrings.cardHolder.toUpperCase(),
                        variant: AppTextVariant.label,
                        color: AppColors.textOnPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        holder.toUpperCase(),
                        variant: AppTextVariant.bodyStrong,
                        color: AppColors.textOnPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      AppStrings.cardExpiry.toUpperCase(),
                      variant: AppTextVariant.label,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      expiry,
                      variant: AppTextVariant.bodyStrong,
                      color: AppColors.textOnPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
