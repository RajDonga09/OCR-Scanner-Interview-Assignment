import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/common_scaffold.dart';
import '../../../card_scanner/presentation/pages/card_scanner_page.dart';
import '../../../passbook_scanner/presentation/pages/passbook_scanner_page.dart';
import '../widgets/home_feature_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: AppStrings.homeTitle,
      showBack: false,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.v4,
          const AppText(
            AppStrings.homeTitle,
            variant: AppTextVariant.display,
          ),
          AppSpacing.v8,
          const AppText(
            AppStrings.homeSubtitle,
            variant: AppTextVariant.body,
            color: AppColors.textSecondary,
          ),
          AppSpacing.v24,
          HomeFeatureTile(
            title: AppStrings.scanCard,
            description: AppStrings.scanCardDescription,
            icon: Icons.credit_card_rounded,
            gradient: const LinearGradient(
              colors: [
                AppColors.cardGradientStart,
                AppColors.cardGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => Navigator.of(context).push(CardScannerPage.route()),
          ),
          AppSpacing.v16,
          HomeFeatureTile(
            title: AppStrings.scanPassbook,
            description: AppStrings.scanPassbookDescription,
            icon: Icons.account_balance_rounded,
            gradient: const LinearGradient(
              colors: [
                AppColors.passbookGradientStart,
                AppColors.passbookGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () =>
                Navigator.of(context).push(PassbookScannerPage.route()),
          ),
          AppSpacing.v32,
        ],
      ),
    );
  }
}
