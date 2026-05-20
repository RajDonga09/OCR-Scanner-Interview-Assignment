import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_image_preview.dart';
import '../../../../core/widgets/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/common_scaffold.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../card_scanner/presentation/widgets/raw_text_view.dart';
import '../../domain/models/bank_details.dart';
import '../cubit/passbook_scanner_cubit.dart';
import '../widgets/passbook_visual.dart';

class PassbookResultPage extends StatelessWidget {
  const PassbookResultPage({
    super.key,
    required this.image,
    required this.details,
    required this.rawText,
    required this.cubit,
  });

  static Route<void> route({
    required File image,
    required BankDetails details,
    required String rawText,
    required PassbookScannerCubit cubit,
  }) {
    return MaterialPageRoute(
      builder: (_) => PassbookResultPage(
        image: image,
        details: details,
        rawText: rawText,
        cubit: cubit,
      ),
    );
  }

  final File image;
  final BankDetails details;
  final String rawText;
  final PassbookScannerCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassbookScannerCubit>.value(
      value: cubit,
      child: CommonScaffold(
        title: AppStrings.scanResultTitle,
        scrollable: true,
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final ifscColor =
        details.isIfscValid ? AppColors.success : AppColors.error;
    final ifscLabel = details.ifsc == null
        ? AppStrings.notDetected
        : details.isIfscValid
            ? '${details.ifsc} (valid)'
            : '${details.ifsc} (invalid)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.v4,
        PassbookVisual(details: details),
        AppSpacing.v20,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(AppStrings.extractedData,
                  variant: AppTextVariant.bodyStrong),
              AppSpacing.v4,
              InfoRow(
                label: AppStrings.accountHolder,
                value: details.accountHolder,
                icon: Icons.person_rounded,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.accountNumber,
                value: details.accountNumber,
                icon: Icons.numbers_rounded,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.ifsc,
                value: ifscLabel,
                icon: Icons.verified_user_rounded,
                valueColor: details.ifsc == null ? null : ifscColor,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.bankName,
                value: details.bankName,
                icon: Icons.account_balance_rounded,
              ),
              const Divider(height: 1),
              InfoRow(
                label: AppStrings.branch,
                value: details.branch,
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
        AppSpacing.v16,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(AppStrings.preview,
                  variant: AppTextVariant.bodyStrong),
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
