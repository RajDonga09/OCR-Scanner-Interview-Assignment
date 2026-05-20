part of 'passbook_scanner_cubit.dart';

enum PassbookScannerStatus { initial, loading, success, failure }

class PassbookScannerState extends Equatable {
  const PassbookScannerState({
    this.status = PassbookScannerStatus.initial,
    this.image,
    this.details,
    this.rawText,
    this.errorMessage,
  });

  factory PassbookScannerState.initial() => const PassbookScannerState();

  final PassbookScannerStatus status;
  final File? image;
  final BankDetails? details;
  final String? rawText;
  final String? errorMessage;

  bool get isLoading => status == PassbookScannerStatus.loading;
  bool get isSuccess => status == PassbookScannerStatus.success;
  bool get isFailure => status == PassbookScannerStatus.failure;

  PassbookScannerState copyWith({
    PassbookScannerStatus? status,
    File? image,
    BankDetails? details,
    String? rawText,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PassbookScannerState(
      status: status ?? this.status,
      image: image ?? this.image,
      details: details ?? this.details,
      rawText: rawText ?? this.rawText,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, image?.path, details, rawText, errorMessage];
}
