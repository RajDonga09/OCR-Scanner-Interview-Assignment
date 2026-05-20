/// Centralised dimensions and spacing values.
///
/// Using a single source for spacing keeps the UI visually consistent and
/// makes layout tweaks trivial.
class AppDimensions {
  const AppDimensions._();

  // Spacing scale (4-pt grid)
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // Radii
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // Component sizing
  static const double buttonHeight = 52;
  static const double textFieldHeight = 56;
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Image / preview
  static const double imagePreviewHeight = 220;

  // Border
  static const double borderWidth = 1;
  static const double borderWidthThick = 1.5;

  // Typography sizes
  static const double fontXs = 12;
  static const double fontSm = 14;
  static const double fontMd = 16;
  static const double fontLg = 20;
  static const double fontXl = 24;
  static const double fontXxl = 32;
}
