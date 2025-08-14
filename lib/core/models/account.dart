class Account {
  final String id;
  final String name;
  final String type;
  final String currency;
  final double balance;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    this.icon,
    this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      currency: map['currency'],
      balance: map['balance'].toDouble(),
      icon: map['icon'],
      color: map['color'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'currency': currency,
      'balance': balance,
      'icon': icon,
      'color': color,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Account copyWith({
    String? name,
    String? type,
    String? currency,
    double? balance,
    String? icon,
    String? color,
    bool? isActive,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
