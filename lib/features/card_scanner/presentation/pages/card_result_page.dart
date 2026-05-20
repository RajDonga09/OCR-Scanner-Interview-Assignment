import 'package:ocr_interview_assignment/dependency.dart';
import 'package:ocr_interview_assignment/features/card_scanner/card_scanner.dart';

class CardResultPage extends StatelessWidget {
  const CardResultPage({
    super.key,
    required this.image,
    required this.details,
    required this.rawText,
    required this.cubit,
  });

  static Route<void> route({
    required File image,
    required CardDetails details,
    required String rawText,
    required CardScannerCubit cubit,
  }) {
    return MaterialPageRoute(
      builder: (_) => CardResultPage(
        image: image,
        details: details,
        rawText: rawText,
        cubit: cubit,
      ),
    );
  }

  final File image;
  final CardDetails details;
  final String rawText;
  final CardScannerCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardScannerCubit>.value(
      value: cubit,
      child: CommonScaffold(
        title: AppStrings.scanResultTitle,
        scrollable: true,
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final luhnColor = details.isLuhnValid ? AppColors.success : AppColors.error;
    final luhnLabel = details.isLuhnValid
        ? AppStrings.luhnPassed
        : AppStrings.luhnFailed;
    final formattedNumber = details.cardNumber == null
        ? AppStrings.notDetected
        : ParserHelper.formatCardNumber(details.cardNumber!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.v4,
        CardVisual(details: details),
        AppSpacing.v20,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                AppStrings.extractedData,
                variant: AppTextVariant.bodyStrong,
              ),
              AppSpacing.v4,
              InfoRow(
                label: AppStrings.cardNumber,
                value: formattedNumber,
                icon: Icons.credit_card_rounded,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.maskedCardNumber,
                value: details.maskedNumber,
                icon: Icons.password_rounded,
                copyable: false,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.cardHolder,
                value: details.holderName,
                icon: Icons.person_rounded,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.cardExpiry,
                value: details.expiry,
                icon: Icons.calendar_month_rounded,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.cardBrand,
                value: details.brand.displayName,
                icon: Icons.style_rounded,
                copyable: false,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.luhnValid,
                value: luhnLabel,
                icon: Icons.verified_user_rounded,
                copyable: false,
                valueColor: luhnColor,
              ),
            ],
          ),
        ),
        AppSpacing.v16,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                AppStrings.preview,
                variant: AppTextVariant.bodyStrong,
              ),
              AppSpacing.v8,
              AppImagePreview(file: image),
            ],
          ),
        ),
        AppSpacing.v16,
        RawTextView(text: rawText),
        AppSpacing.v24,
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: AppStrings.rescan,
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  cubit.reset();
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: AppButton(
                label: AppStrings.done,
                icon: Icons.check_rounded,
                onPressed: () {
                  cubit.reset();
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
              ),
            ),
          ],
        ),
        AppSpacing.v16,
      ],
    );
  }
}
