import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/image_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/card_details.dart';
import '../../domain/repositories/card_scanner_repository.dart';

part 'card_scanner_state.dart';

/// Cubit that owns the lifecycle of a single card scan.
///
/// The cubit is intentionally tiny — all parsing/IO logic lives in
/// [CardScannerRepository]. That separation keeps the cubit purely a state
/// machine that is trivial to test with `bloc_test`.
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
