/// Centralised asset paths.
///
/// The project does not currently ship custom raster assets — instead we
/// rely on Material icons. This file is kept so future assets land in a
/// single, predictable location and screens never reference hard-coded
/// strings.
class AppAssets {
  const AppAssets._();

  static const String assetsRoot = 'assets/';
  static const String imagesRoot = '${assetsRoot}images/';
  static const String iconsRoot = '${assetsRoot}icons/';

  // Placeholder paths — referenced via theme/icons rather than raster assets
  // today, but documented here so they are easy to add without rewiring code.
  static const String placeholderCard = '${imagesRoot}card_placeholder.png';
  static const String placeholderPassbook =
      '${imagesRoot}passbook_placeholder.png';
}
