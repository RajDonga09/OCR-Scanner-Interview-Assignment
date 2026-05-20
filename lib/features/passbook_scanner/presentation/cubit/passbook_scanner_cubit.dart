import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/image_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/bank_details.dart';
import '../../domain/repositories/passbook_scanner_repository.dart';

part 'passbook_scanner_state.dart';

class PassbookScannerCubit extends Cubit<PassbookScannerState> {
  PassbookScannerCubit({required this.repository})
      : super(PassbookScannerState.initial());

  final PassbookScannerRepository repository;

  Future<void> scanWithCamera() => _scan(AppImageSource.camera);

  Future<void> scanWithGallery() => _scan(AppImageSource.gallery);

  void reset() => emit(PassbookScannerState.initial());

  Future<void> _scan(AppImageSource source) async {
    emit(state.copyWith(
      status: PassbookScannerStatus.loading,
      clearError: true,
    ));

    try {
      final result = await repository.scan(source);
      emit(state.copyWith(
        status: PassbookScannerStatus.success,
        image: result.image,
        details: result.details,
        rawText: result.rawText,
        clearError: true,
      ));
    } on PassbookScanCropCancelledFailure {
      emit(PassbookScannerState.initial());
    } on PassbookScanFailure catch (e) {
      AppLogger.error('Passbook scan failed', error: e);
      emit(state.copyWith(
        status: PassbookScannerStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e, stack) {
      AppLogger.error(
        'Passbook scan crashed unexpectedly',
        error: e,
        stackTrace: stack,
      );
      emit(state.copyWith(
        status: PassbookScannerStatus.failure,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }
}
