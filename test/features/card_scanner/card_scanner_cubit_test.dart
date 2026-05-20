import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocr_interview_assignment/core/services/image_service.dart';
import 'package:ocr_interview_assignment/features/card_scanner/domain/models/card_details.dart';
import 'package:ocr_interview_assignment/features/card_scanner/domain/repositories/card_scanner_repository.dart';
import 'package:ocr_interview_assignment/features/card_scanner/presentation/cubit/card_scanner_cubit.dart';

class _MockRepository extends Mock implements CardScannerRepository {}

class _FakeFile extends Fake implements File {
  @override
  String get path => '/tmp/fake.png';
}

void main() {
  setUpAll(() {
    registerFallbackValue(AppImageSource.gallery);
  });

  late _MockRepository repository;
  final fakeFile = _FakeFile();
  const details = CardDetails(
    cardNumber: '4111111111111111',
    maskedNumber: 'XXXX XXXX XXXX 1111',
    holderName: 'JOHN DOE',
    expiry: '12/25',
    brand: CardBrand.visa,
    isLuhnValid: true,
  );

  setUp(() {
    repository = _MockRepository();
  });

  group('CardScannerCubit', () {
    blocTest<CardScannerCubit, CardScannerState>(
      'emits loading -> success on a successful scan',
      build: () {
        when(() => repository.scan(any())).thenAnswer(
          (_) async => CardScanResult(
            image: fakeFile,
            details: details,
            rawText: 'raw',
          ),
        );
        return CardScannerCubit(repository: repository);
      },
      act: (cubit) => cubit.scanWithGallery(),
      expect: () => [
        isA<CardScannerState>()
            .having((s) => s.status, 'status', CardScannerStatus.loading),
        isA<CardScannerState>()
            .having((s) => s.status, 'status', CardScannerStatus.success)
            .having((s) => s.details, 'details', details)
            .having((s) => s.rawText, 'rawText', 'raw'),
      ],
    );

    blocTest<CardScannerCubit, CardScannerState>(
      'emits loading -> failure when the repository throws CardScanFailure',
      build: () {
        when(() => repository.scan(any())).thenThrow(
          const CardScanOcrFailure('OCR failed'),
        );
        return CardScannerCubit(repository: repository);
      },
      act: (cubit) => cubit.scanWithCamera(),
      expect: () => [
        isA<CardScannerState>()
            .having((s) => s.status, 'status', CardScannerStatus.loading),
        isA<CardScannerState>()
            .having((s) => s.status, 'status', CardScannerStatus.failure)
            .having((s) => s.errorMessage, 'message', 'OCR failed'),
      ],
    );

    blocTest<CardScannerCubit, CardScannerState>(
      'reset() returns the cubit to its initial state',
      build: () => CardScannerCubit(repository: repository),
      seed: () => const CardScannerState(
        status: CardScannerStatus.failure,
        errorMessage: 'boom',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [CardScannerState.initial()],
    );
  });
}
