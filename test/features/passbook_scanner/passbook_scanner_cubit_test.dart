import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocr_interview_assignment/core/services/image_service.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/domain/models/bank_details.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/domain/repositories/passbook_scanner_repository.dart';
import 'package:ocr_interview_assignment/features/passbook_scanner/presentation/cubit/passbook_scanner_cubit.dart';

class _MockRepository extends Mock implements PassbookScannerRepository {}

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
  const details = BankDetails(
    accountHolder: 'JOHN DOE',
    accountNumber: '123456789012',
    ifsc: 'HDFC0001234',
    isIfscValid: true,
  );

  setUp(() {
    repository = _MockRepository();
  });

  group('PassbookScannerCubit', () {
    blocTest<PassbookScannerCubit, PassbookScannerState>(
      'emits loading -> success on a successful scan',
      build: () {
        when(() => repository.scan(any())).thenAnswer(
          (_) async => PassbookScanResult(
            image: fakeFile,
            details: details,
            rawText: 'raw',
          ),
        );
        return PassbookScannerCubit(repository: repository);
      },
      act: (cubit) => cubit.scanWithGallery(),
      expect: () => [
        isA<PassbookScannerState>()
            .having((s) => s.status, 'status', PassbookScannerStatus.loading),
        isA<PassbookScannerState>()
            .having((s) => s.status, 'status', PassbookScannerStatus.success)
            .having((s) => s.details, 'details', details)
            .having((s) => s.rawText, 'rawText', 'raw'),
      ],
    );

    blocTest<PassbookScannerCubit, PassbookScannerState>(
      'emits loading -> failure when the repository throws PassbookScanFailure',
      build: () {
        when(() => repository.scan(any())).thenThrow(
          const PassbookScanOcrFailure('Boom'),
        );
        return PassbookScannerCubit(repository: repository);
      },
      act: (cubit) => cubit.scanWithCamera(),
      expect: () => [
        isA<PassbookScannerState>()
            .having((s) => s.status, 'status', PassbookScannerStatus.loading),
        isA<PassbookScannerState>()
            .having((s) => s.status, 'status', PassbookScannerStatus.failure)
            .having((s) => s.errorMessage, 'message', 'Boom'),
      ],
    );

    blocTest<PassbookScannerCubit, PassbookScannerState>(
      'reset() restores initial state',
      build: () => PassbookScannerCubit(repository: repository),
      seed: () => const PassbookScannerState(
        status: PassbookScannerStatus.failure,
        errorMessage: 'boom',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [PassbookScannerState.initial()],
    );
  });
}
