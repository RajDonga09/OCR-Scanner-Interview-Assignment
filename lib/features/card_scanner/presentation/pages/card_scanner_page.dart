import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_image_preview.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/common_scaffold.dart';
import '../cubit/card_scanner_cubit.dart';
import '../widgets/card_scanner_actions.dart';
import 'card_result_page.dart';

class CardScannerPage extends StatelessWidget {
  const CardScannerPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const CardScannerPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardScannerCubit>(
      create: (_) => sl<CardScannerCubit>(),
      child: const _CardScannerView(),
    );
  }
}

class _CardScannerView extends StatelessWidget {
  const _CardScannerView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardScannerCubit, CardScannerState>(
      listener: (context, state) {
        if (state.isSuccess && state.details != null) {
          Navigator.of(context).push(
            CardResultPage.route(
              image: state.image!,
              details: state.details!,
              rawText: state.rawText ?? '',
              cubit: context.read<CardScannerCubit>(),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CardScannerCubit>();
        return CommonScaffold(
          title: AppStrings.cardScannerTitle,
          body: _buildBody(context, state, cubit),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CardScannerState state,
    CardScannerCubit cubit,
  ) {
    if (state.isLoading) {
      return const AppLoader(message: AppStrings.loading);
    }

    if (state.isFailure) {
      return AppErrorView(
        message: state.errorMessage ?? AppStrings.errorTitle,
        onRetry: cubit.reset,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.v4,
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: const Icon(
                          Icons.credit_card_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.h12,
                      const Expanded(
                        child: AppText(
                          AppStrings.cardScannerHint,
                          variant: AppTextVariant.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.v20,
                const AppImagePreview(
                  file: null,
                  placeholderLabel: 'Tap a button below to start',
                ),
                AppSpacing.v24,
                const AppEmptyView(
                  title: AppStrings.emptyTitle,
                  message:
                      'Scan a credit or debit card to extract its number, holder name and expiry date.',
                  icon: Icons.credit_score_rounded,
                ),
              ],
            ),
          ),
        ),
        AppSpacing.v16,
        CardScannerActions(
          onCamera: cubit.scanWithCamera,
          onGallery: cubit.scanWithGallery,
        ),
      ],
    );
  }
}
