import 'package:finvault/core/database/database_helper.dart';
import 'package:finvault/core/models/transaction.dart';
import 'package:finvault/core/services/account_service.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  static final TransactionService instance = TransactionService._init();
  TransactionService._init();

  final _uuid = const Uuid();

  Future<List<Transaction>> getAllTransactions({int? limit}) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT t.*, a.name as accountName, c.name as categoryName, 
             c.icon as categoryIcon, c.color as categoryColor
      FROM transactions t
      LEFT JOIN accounts a ON t.accountId = a.id
      LEFT JOIN categories c ON t.categoryId = c.id
      ORDER BY t.date DESC, t.createdAt DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByAccount(String accountId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT t.*, a.name as accountName, c.name as categoryName, 
             c.icon as categoryIcon, c.color as categoryColor
      FROM transactions t
      LEFT JOIN accounts a ON t.accountId = a.id
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.accountId = ?
      ORDER BY t.date DESC, t.createdAt DESC
    ''', [accountId]);
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT t.*, a.name as accountName, c.name as categoryName, 
             c.icon as categoryIcon, c.color as categoryColor
      FROM transactions t
      LEFT JOIN accounts a ON t.accountId = a.id
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.categoryId = ?
      ORDER BY t.date DESC, t.createdAt DESC
    ''', [categoryId]);
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<String> createTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final transactionWithId = Transaction(
      id: id,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      type: transaction.type,
      description: transaction.description,
      date: transaction.date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('transactions', transactionWithId.toMap());

    // Update account balance
    await _updateAccountBalance(
        transaction.accountId, transaction.amount, transaction.type);

    return id;
  }

  Future<void> updateTransaction(
      Transaction oldTransaction, Transaction newTransaction) async {
    final db = await DatabaseHelper.instance.database;

    // Revert old transaction impact on account balance
    await _updateAccountBalance(
      oldTransaction.accountId,
      -oldTransaction.amount,
      oldTransaction.type,
    );

    // Apply new transaction impact
    await _updateAccountBalance(
      newTransaction.accountId,
      newTransaction.amount,
      newTransaction.type,
    );

    await db.update(
      'transactions',
      newTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [newTransaction.id],
    );
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    final db = await DatabaseHelper.instance.database;

    // Revert transaction impact on account balance
    await _updateAccountBalance(
      transaction.accountId,
      -transaction.amount,
      transaction.type,
    );

    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> _updateAccountBalance(
      String accountId, double amount, String type) async {
    final account = await AccountService.instance.getAccountById(accountId);
    if (account != null) {
      double balanceChange = type == 'income' ? amount : -amount;
      double newBalance = account.balance + balanceChange;
      await AccountService.instance.updateBalance(accountId, newBalance);
    }
  }

  Future<Map<String, double>> getMonthlyStats() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE date >= ?
      GROUP BY type
    ''', [startOfMonth]);

    double income = 0;
    double expense = 0;

    for (final row in result) {
      if (row['type'] == 'income') {
        income = (row['total'] as num).toDouble();
      } else if (row['type'] == 'expense') {
        expense = (row['total'] as num).toDouble();
      }
    }

    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
    };
  }

  Future<List<Transaction>> getTransactionsByTypeForCurrentMonth(String type) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final maps = await db.rawQuery('''
      SELECT t.*, a.name as accountName, c.name as categoryName,
             c.icon as categoryIcon, c.color as categoryColor
      FROM transactions t
      LEFT JOIN accounts a ON t.accountId = a.id
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.type = ? AND t.date >= ?
      ORDER BY t.date DESC, t.createdAt DESC
    ''', [type, startOfMonth]);

    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Map<String, double>> getCurrentMonthCategoryTotals(String type) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final rows = await db.rawQuery('''
      SELECT c.name as categoryName, SUM(t.amount) as total
      FROM transactions t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.type = ? AND t.date >= ?
      GROUP BY c.name
      ORDER BY total DESC
    ''', [type, startOfMonth]);

    final Map<String, double> result = {};
    for (final row in rows) {
      final name = (row['categoryName'] as String?) ?? 'Unknown';
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      result[name] = total;
    }
    return result;
  }
}
