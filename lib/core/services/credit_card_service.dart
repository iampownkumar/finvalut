import '../database/database_helper.dart';
import '../models/credit_card.dart';
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
    return maps.map((map) => CreditCard.fromMap(map)).toList();
  }

  Future<CreditCard?> getCreditCardById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CreditCard.fromMap(maps.first);
    }
    return null;
  }

  Future<String> createCreditCard(CreditCard creditCard) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final cardWithId = CreditCard(
      id: id,
      bankName: creditCard.bankName,
      cardNumber: creditCard.cardNumber,
      cardLimit: creditCard.cardLimit,
      usedAmount: creditCard.usedAmount,
      billDate: creditCard.billDate,
      paymentDate: creditCard.paymentDate,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('credit_cards', cardWithId.toMap());
    return id;
  }

  Future<void> updateCreditCard(CreditCard creditCard) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'credit_cards',
      creditCard.toMap(),
      where: 'id = ?',
      whereArgs: [creditCard.id],
    );
  }

  Future<void> deleteCreditCard(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'credit_cards',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUsedAmount(String cardId, double newUsedAmount) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'credit_cards',
      {
        'usedAmount': newUsedAmount,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<Map<String, double>> getCreditCardStats() async {
    final cards = await getAllCreditCards();

    double totalLimit = 0;
    double totalUsed = 0;
    int overLimitCards = 0;
    int nearLimitCards = 0;

    for (final card in cards) {
      totalLimit += card.cardLimit;
      totalUsed += card.usedAmount;

      if (card.isOverLimit) overLimitCards++;
      if (card.isNearLimit) nearLimitCards++;
    }

    return {
      'totalLimit': totalLimit,
      'totalUsed': totalUsed,
      'availableLimit': totalLimit - totalUsed,
      'utilizationPercentage':
          totalLimit > 0 ? (totalUsed / totalLimit) * 100 : 0,
      'overLimitCards': overLimitCards.toDouble(),
      'nearLimitCards': nearLimitCards.toDouble(),
      'totalCards': cards.length.toDouble(),
    };
  }

  Future<List<CreditCard>> getCardsNearLimit() async {
    final cards = await getAllCreditCards();
    return cards.where((card) => card.isNearLimit || card.isOverLimit).toList();
  }
}
