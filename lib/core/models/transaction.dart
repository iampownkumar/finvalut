class Transaction {
  final String id;
  final String accountId;
  final String categoryId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated from joins
  String? accountName;
  String? categoryName;
  String? categoryIcon;
  String? categoryColor;

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.accountName,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      categoryId: map['categoryId'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      accountName: map['accountName'],
      categoryName: map['categoryName'],
      categoryIcon: map['categoryIcon'],
      categoryColor: map['categoryColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'categoryId': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? accountId,
    String? categoryId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
