import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocr_interview_assignment/core/core.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.copyable = true,
    this.valueColor,
  });

  final String label;
  final String? value;
  final IconData? icon;
  final bool copyable;
  final Color? valueColor;

  bool get _hasValue => value != null && value!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final displayValue = _hasValue ? value! : AppStrings.notDetected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconSm,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label.toUpperCase(), variant: AppTextVariant.label),
                const SizedBox(height: 2),
                AppText(
                  displayValue,
                  variant: AppTextVariant.bodyStrong,
                  color: _hasValue
                      ? valueColor ?? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (copyable && _hasValue)
            IconButton(
              icon: const Icon(
                Icons.copy_rounded,
                size: AppDimensions.iconSm,
                color: AppColors.textMuted,
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value!));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(milliseconds: 1200),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
