import 'package:ocr_interview_assignment/dependency.dart';

class BankDetails extends Equatable {
  const BankDetails({
    this.accountHolder,
    this.accountNumber,
    this.ifsc,
    this.bankName,
    this.branch,
    this.isIfscValid = false,
  });

  factory BankDetails.empty() => const BankDetails();

  final String? accountHolder;
  final String? accountNumber;
  final String? ifsc;
  final String? bankName;
  final String? branch;
  final bool isIfscValid;

  bool get hasData =>
      accountHolder != null || accountNumber != null || ifsc != null;

  BankDetails copyWith({
    String? accountHolder,
    String? accountNumber,
    String? ifsc,
    String? bankName,
    String? branch,
    bool? isIfscValid,
  }) {
    return BankDetails(
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      ifsc: ifsc ?? this.ifsc,
      bankName: bankName ?? this.bankName,
      branch: branch ?? this.branch,
      isIfscValid: isIfscValid ?? this.isIfscValid,
    );
  }

  Map<String, dynamic> toJson() => {
    'accountHolder': accountHolder,
    'accountNumber': accountNumber,
    'ifsc': ifsc,
    'bankName': bankName,
    'branch': branch,
    'isIfscValid': isIfscValid,
  };

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountHolder: json['accountHolder'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifsc: json['ifsc'] as String?,
      bankName: json['bankName'] as String?,
      branch: json['branch'] as String?,
      isIfscValid: json['isIfscValid'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    accountHolder,
    accountNumber,
    ifsc,
    bankName,
    branch,
    isIfscValid,
  ];
}
