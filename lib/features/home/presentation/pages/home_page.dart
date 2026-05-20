import 'package:ocr_interview_assignment/dependency.dart';
import 'package:ocr_interview_assignment/features/card_scanner/card_scanner.dart';
import 'package:ocr_interview_assignment/features/home/home.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/passbook_scanner.dart';

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
          const AppText(AppStrings.homeTitle, variant: AppTextVariant.display),
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
              colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
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
