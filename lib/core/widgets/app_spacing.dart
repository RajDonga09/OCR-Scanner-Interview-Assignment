import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Tiny helpers that replace ad-hoc `SizedBox(height: …)` calls scattered
/// across the codebase.
class AppSpacing {
  const AppSpacing._();

  static const Widget v4 = SizedBox(height: AppDimensions.space4);
  static const Widget v8 = SizedBox(height: AppDimensions.space8);
  static const Widget v12 = SizedBox(height: AppDimensions.space12);
  static const Widget v16 = SizedBox(height: AppDimensions.space16);
  static const Widget v20 = SizedBox(height: AppDimensions.space20);
  static const Widget v24 = SizedBox(height: AppDimensions.space24);
  static const Widget v32 = SizedBox(height: AppDimensions.space32);
  static const Widget v40 = SizedBox(height: AppDimensions.space40);

  static const Widget h4 = SizedBox(width: AppDimensions.space4);
  static const Widget h8 = SizedBox(width: AppDimensions.space8);
  static const Widget h12 = SizedBox(width: AppDimensions.space12);
  static const Widget h16 = SizedBox(width: AppDimensions.space16);
  static const Widget h24 = SizedBox(width: AppDimensions.space24);
}
