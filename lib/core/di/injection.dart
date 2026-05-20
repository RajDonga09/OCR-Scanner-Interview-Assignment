import 'package:get_it/get_it.dart';
import 'package:ocr_interview_assignment/core/core.dart';
import 'package:ocr_interview_assignment/features/card_scanner/card_scanner.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/passbook_scanner.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<OcrService>()) return;

  sl.registerLazySingleton<PermissionService>(
    () => const PermissionServiceImpl(),
  );
  sl.registerLazySingleton<ImageService>(() => ImageServiceImpl());
  sl.registerLazySingleton<ImageCropService>(
    () => const ImageCropServiceImpl(),
  );
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
