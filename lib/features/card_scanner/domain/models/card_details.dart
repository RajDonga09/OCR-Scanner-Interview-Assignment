import 'package:equatable/equatable.dart';

/// High-level card-network classification used to colour the UI.
///
/// We classify based solely on the IIN range; the classification has no
/// effect on parsing accuracy and is purely cosmetic.
enum CardBrand { visa, masterCard, amex, rupay, discover, unknown }

extension CardBrandX on CardBrand {
  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.masterCard:
        return 'MasterCard';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.rupay:
        return 'RuPay';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.unknown:
        return 'Card';
    }
  }
}

/// Immutable value type returned by the card parser.
class CardDetails extends Equatable {
  const CardDetails({
    this.cardNumber,
    this.maskedNumber,
    this.holderName,
    this.expiry,
    this.brand = CardBrand.unknown,
    this.isLuhnValid = false,
  });

  factory CardDetails.empty() => const CardDetails();

  /// Cleaned digit-only PAN.
  final String? cardNumber;

  /// `XXXX XXXX XXXX 1234` form — never logged but safe to display.
  final String? maskedNumber;

  /// Detected card holder name.
  final String? holderName;

  /// Detected expiry date formatted as `MM/YY`.
  final String? expiry;

  final CardBrand brand;

  final bool isLuhnValid;

  bool get hasData =>
      cardNumber != null || holderName != null || expiry != null;

  CardDetails copyWith({
    String? cardNumber,
    String? maskedNumber,
    String? holderName,
    String? expiry,
    CardBrand? brand,
    bool? isLuhnValid,
  }) {
    return CardDetails(
      cardNumber: cardNumber ?? this.cardNumber,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      holderName: holderName ?? this.holderName,
      expiry: expiry ?? this.expiry,
      brand: brand ?? this.brand,
      isLuhnValid: isLuhnValid ?? this.isLuhnValid,
    );
  }

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'maskedNumber': maskedNumber,
        'holderName': holderName,
        'expiry': expiry,
        'brand': brand.name,
        'isLuhnValid': isLuhnValid,
      };

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      cardNumber: json['cardNumber'] as String?,
      maskedNumber: json['maskedNumber'] as String?,
      holderName: json['holderName'] as String?,
      expiry: json['expiry'] as String?,
      brand: CardBrand.values.firstWhere(
        (b) => b.name == json['brand'],
        orElse: () => CardBrand.unknown,
      ),
      isLuhnValid: json['isLuhnValid'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [cardNumber, maskedNumber, holderName, expiry, brand, isLuhnValid];
}
