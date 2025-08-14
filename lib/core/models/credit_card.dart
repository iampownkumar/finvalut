class CreditCard {
  final String id;
  final String bankName;
  final String cardNumber; // Last 4 digits only for security
  final double cardLimit;
  final double usedAmount;
  final int billDate; // Day of month (1-31)
  final int paymentDate; // Day of month (1-31)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreditCard({
    required this.id,
    required this.bankName,
    required this.cardNumber,
    required this.cardLimit,
    required this.usedAmount,
    required this.billDate,
    required this.paymentDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  double get availableLimit => cardLimit - usedAmount;
  double get utilizationPercentage =>
      cardLimit > 0 ? (usedAmount / cardLimit) * 100 : 0;

  bool get isOverLimit => usedAmount > cardLimit;
  bool get isNearLimit => utilizationPercentage >= 80;

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'],
      bankName: map['bankName'],
      cardNumber: map['cardNumber'],
      cardLimit: map['cardLimit'].toDouble(),
      usedAmount: map['usedAmount'].toDouble(),
      billDate: map['billDate'],
      paymentDate: map['paymentDate'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'cardNumber': cardNumber,
      'cardLimit': cardLimit,
      'usedAmount': usedAmount,
      'billDate': billDate,
      'paymentDate': paymentDate,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CreditCard copyWith({
    String? bankName,
    String? cardNumber,
    double? cardLimit,
    double? usedAmount,
    int? billDate,
    int? paymentDate,
    bool? isActive,
  }) {
    return CreditCard(
      id: id,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardLimit: cardLimit ?? this.cardLimit,
      usedAmount: usedAmount ?? this.usedAmount,
      billDate: billDate ?? this.billDate,
      paymentDate: paymentDate ?? this.paymentDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
