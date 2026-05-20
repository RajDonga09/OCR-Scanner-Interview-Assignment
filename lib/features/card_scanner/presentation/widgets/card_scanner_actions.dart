import 'package:ocr_interview_assignment/dependency.dart';

class CardScannerActions extends StatelessWidget {
  const CardScannerActions({
    super.key,
    required this.onCamera,
    required this.onGallery,
    this.isLoading = false,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: AppStrings.useCamera,
          icon: Icons.photo_camera_rounded,
          onPressed: isLoading ? null : onCamera,
          isLoading: isLoading,
        ),
        AppSpacing.v12,
        AppButton(
          label: AppStrings.useGallery,
          icon: Icons.photo_library_rounded,
          onPressed: isLoading ? null : onGallery,
          variant: AppButtonVariant.outline,
        ),
      ],
    );
  }
}
