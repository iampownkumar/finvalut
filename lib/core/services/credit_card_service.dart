import 'package:finvault/core/database/database_helper.dart';
import 'package:finvault/core/models/credit_card.dart';
import 'package:uuid/uuid.dart';

class CreditCardService {
  static final CreditCardService instance = CreditCardService._init();
  CreditCardService._init();

  final _uuid = const Uuid();

  Future<List<CreditCard>> getAllCreditCards() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'credit_cards',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((e) => CreditCard.fromMap(e)).toList();
  }

  Future<CreditCard?> getCreditCardById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('credit_cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return CreditCard.fromMap(maps.first);
    return null;
  }

  Future<String> createCreditCard(CreditCard card) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final withId = CreditCard(
      id: id,
      bankName: card.bankName,
      cardNumber: card.cardNumber,
      cardLimit: card.cardLimit,
      usedAmount: card.usedAmount,
      billDate: card.billDate,
      paymentDate: card.paymentDate,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('credit_cards', withId.toMap());
    return id;
  }

  Future<void> updateCreditCard(CreditCard card) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'credit_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCreditCard(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'credit_cards',
      {
        'isActive': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getCreditCardStats() async {
    final cards = await getAllCreditCards();
    double totalLimit = 0;
    double totalUsed = 0;

    for (final c in cards) {
      totalLimit += c.cardLimit;
      totalUsed += c.usedAmount;
    }

    final available = (totalLimit - totalUsed).clamp(0.0, double.infinity);
    final utilization = totalLimit > 0 ? (totalUsed / totalLimit) * 100.0 : 0.0;

    return {
      'totalLimit': totalLimit,
      'totalUsed': totalUsed,
      'availableLimit': available,
      'utilizationPercentage': utilization,
    };
  }
}
