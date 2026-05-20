import 'package:flutter/material.dart';
import 'package:ocr_interview_assignment/core/core.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.space16),
              AppText(
                message!,
                variant: AppTextVariant.body,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
