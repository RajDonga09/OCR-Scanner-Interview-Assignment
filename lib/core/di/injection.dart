import 'package:get_it/get_it.dart';

import '../services/image_crop_service.dart';
import '../services/image_service.dart';
import '../services/ocr_service.dart';
import '../services/permission_service.dart';
import '../../features/card_scanner/domain/parsers/card_parser.dart';
import '../../features/card_scanner/domain/repositories/card_scanner_repository.dart';
import '../../features/card_scanner/presentation/cubit/card_scanner_cubit.dart';
import '../../features/passbook_scanner/domain/parsers/passbook_parser.dart';
import '../../features/passbook_scanner/domain/repositories/passbook_scanner_repository.dart';
import '../../features/passbook_scanner/presentation/cubit/passbook_scanner_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<OcrService>()) return;

  sl.registerLazySingleton<PermissionService>(() => const PermissionServiceImpl());
  sl.registerLazySingleton<ImageService>(() => ImageServiceImpl());
  sl.registerLazySingleton<ImageCropService>(() => const ImageCropServiceImpl());
  sl.registerLazySingleton<OcrService>(() => MlKitOcrService());

  sl.registerLazySingleton<CardParser>(() => const CardParser());
  sl.registerLazySingleton<CardScannerRepository>(
    () => CardScannerRepositoryImpl(
      imageService: sl<ImageService>(),
      imageCropService: sl<ImageCropService>(),
      ocrService: sl<OcrService>(),
      permissionService: sl<PermissionService>(),
      parser: sl<CardParser>(),
    ),
  );
  sl.registerFactory<CardScannerCubit>(
    () => CardScannerCubit(repository: sl<CardScannerRepository>()),
  );

  sl.registerLazySingleton<PassbookParser>(() => const PassbookParser());
  sl.registerLazySingleton<PassbookScannerRepository>(
    () => PassbookScannerRepositoryImpl(
      imageService: sl<ImageService>(),
      imageCropService: sl<ImageCropService>(),
      ocrService: sl<OcrService>(),
      permissionService: sl<PermissionService>(),
      parser: sl<PassbookParser>(),
    ),
  );
  sl.registerFactory<PassbookScannerCubit>(
    () => PassbookScannerCubit(repository: sl<PassbookScannerRepository>()),
  );
}
