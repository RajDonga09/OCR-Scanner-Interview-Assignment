part of 'card_scanner_cubit.dart';

enum CardScannerStatus { initial, loading, success, failure }

class CardScannerState extends Equatable {
  const CardScannerState({
    this.status = CardScannerStatus.initial,
    this.image,
    this.details,
    this.rawText,
    this.errorMessage,
  });

  factory CardScannerState.initial() => const CardScannerState();

  final CardScannerStatus status;
  final File? image;
  final CardDetails? details;
  final String? rawText;
  final String? errorMessage;

  bool get isLoading => status == CardScannerStatus.loading;
  bool get isSuccess => status == CardScannerStatus.success;
  bool get isFailure => status == CardScannerStatus.failure;

  CardScannerState copyWith({
    CardScannerStatus? status,
    File? image,
    CardDetails? details,
    String? rawText,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CardScannerState(
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
