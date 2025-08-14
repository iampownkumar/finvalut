class Loan {
  final String id;
  final String title;
  final double amount;
  final String type; // 'given' or 'taken'
  final double interestRate;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyPayment;
  final double remainingAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.interestRate,
    required this.startDate,
    required this.endDate,
    required this.monthlyPayment,
    required this.remainingAmount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  double get paidAmount => amount - remainingAmount;
  double get completionPercentage =>
      amount > 0 ? (paidAmount / amount) * 100 : 0;

  int get remainingMonths {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays ~/ 30;
  }

  bool get isOverdue => DateTime.now().isAfter(endDate) && remainingAmount > 0;
  bool get isDueSoon => remainingMonths <= 3 && remainingAmount > 0;

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      interestRate: map['interestRate'].toDouble(),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      monthlyPayment: map['monthlyPayment'].toDouble(),
      remainingAmount: map['remainingAmount'].toDouble(),
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'interestRate': interestRate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'monthlyPayment': monthlyPayment,
      'remainingAmount': remainingAmount,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Loan copyWith({
    String? title,
    double? amount,
    String? type,
    double? interestRate,
    DateTime? startDate,
    DateTime? endDate,
    double? monthlyPayment,
    double? remainingAmount,
    bool? isActive,
  }) {
    return Loan(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
