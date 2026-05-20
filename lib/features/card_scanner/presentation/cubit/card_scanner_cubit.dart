import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/image_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/card_details.dart';
import '../../domain/repositories/card_scanner_repository.dart';

part 'card_scanner_state.dart';

class CardScannerCubit extends Cubit<CardScannerState> {
  CardScannerCubit({required this.repository})
      : super(CardScannerState.initial());

  final CardScannerRepository repository;

  Future<void> scanWithCamera() => _scan(AppImageSource.camera);

  Future<void> scanWithGallery() => _scan(AppImageSource.gallery);

  void reset() => emit(CardScannerState.initial());

  Future<void> _scan(AppImageSource source) async {
    emit(state.copyWith(
      status: CardScannerStatus.loading,
      clearError: true,
    ));

    try {
      final result = await repository.scan(source);
      emit(state.copyWith(
        status: CardScannerStatus.success,
        image: result.image,
        details: result.details,
        rawText: result.rawText,
        clearError: true,
      ));
    } on CardScanCropCancelledFailure {
      emit(CardScannerState.initial());
    } on CardScanFailure catch (e) {
      AppLogger.error('Card scan failed', error: e);
      emit(state.copyWith(
        status: CardScannerStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e, stack) {
      AppLogger.error(
        'Card scan crashed unexpectedly',
        error: e,
        stackTrace: stack,
      );
      emit(state.copyWith(
        status: CardScannerStatus.failure,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }
}
