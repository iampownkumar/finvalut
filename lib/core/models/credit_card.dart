class CreditCard {
  final String id;
  final String bankName;
  final String cardNumber; // typically masked (e.g., ****1234)
  final double cardLimit;
  final double usedAmount;
  final int billDate; // day of month 1-31
  final int paymentDate; // day of month 1-31
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditCard({
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

  // Computed helpers
  double get availableLimit => (cardLimit - usedAmount) < 0 ? 0 : (cardLimit - usedAmount);
  double get utilizationPercentage => cardLimit > 0 ? (usedAmount / cardLimit) * 100.0 : 0.0;
  bool get isOverLimit => usedAmount > cardLimit;
  bool get isNearLimit => !isOverLimit && cardLimit > 0 && (usedAmount / cardLimit) >= 0.8;

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as String,
      bankName: map['bankName'] as String,
      cardNumber: map['cardNumber'] as String,
      cardLimit: (map['cardLimit'] as num).toDouble(),
      usedAmount: (map['usedAmount'] as num).toDouble(),
      billDate: (map['billDate'] as num).toInt(),
      paymentDate: (map['paymentDate'] as num).toInt(),
      isActive: (map['isActive'] as num) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
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
