import 'package:ocr_interview_assignment/dependency.dart';

class RawTextView extends StatefulWidget {
  const RawTextView({super.key, required this.text});

  final String text;

  @override
  State<RawTextView> createState() => _RawTextViewState();
}

class _RawTextViewState extends State<RawTextView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.text_snippet_outlined,
                size: AppDimensions.iconSm,
                color: AppColors.textSecondary,
              ),
              AppSpacing.h8,
              const AppText(
                AppStrings.rawText,
                variant: AppTextVariant.bodyStrong,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Hide' : 'Show'),
              ),
            ],
          ),
          if (_expanded) ...[
            AppSpacing.v8,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: AppText(
                widget.text,
                variant: AppTextVariant.caption,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
