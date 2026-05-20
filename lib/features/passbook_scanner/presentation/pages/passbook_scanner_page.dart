import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_image_preview.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/common_scaffold.dart';
import '../cubit/passbook_scanner_cubit.dart';
import '../widgets/passbook_scanner_actions.dart';
import 'passbook_result_page.dart';

class PassbookScannerPage extends StatelessWidget {
  const PassbookScannerPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const PassbookScannerPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassbookScannerCubit>(
      create: (_) => sl<PassbookScannerCubit>(),
      child: const _PassbookScannerView(),
    );
  }
}

class _PassbookScannerView extends StatelessWidget {
  const _PassbookScannerView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassbookScannerCubit, PassbookScannerState>(
      listener: (context, state) {
        if (state.isSuccess && state.details != null) {
          Navigator.of(context).push(
            PassbookResultPage.route(
              image: state.image!,
              details: state.details!,
              rawText: state.rawText ?? '',
              cubit: context.read<PassbookScannerCubit>(),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PassbookScannerCubit>();
        return CommonScaffold(
          title: AppStrings.passbookScannerTitle,
          body: _buildBody(context, state, cubit),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    PassbookScannerState state,
    PassbookScannerCubit cubit,
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
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                      AppSpacing.h12,
                      const Expanded(
                        child: AppText(
                          AppStrings.passbookScannerHint,
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
                // AppSpacing.v24,
                // const AppEmptyView(
                //   title: AppStrings.emptyTitle,
                //   message:
                //       'Scan a passbook page to extract the holder name, account number and IFSC code.',
                //   icon: Icons.menu_book_rounded,
                // ),
              ],
            ),
          ),
        ),
        AppSpacing.v16,
        PassbookScannerActions(
          onCamera: cubit.scanWithCamera,
          onGallery: cubit.scanWithGallery,
        ),
      ],
    );
  }
}
