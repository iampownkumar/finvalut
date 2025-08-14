import 'package:finvault/core/database/database_helper.dart';
import 'package:finvault/core/models/account.dart';
import 'package:uuid/uuid.dart';

class AccountService {
  static final AccountService instance = AccountService._init();
  AccountService._init();

  final _uuid = const Uuid();

  Future<List<Account>> getAllAccounts() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'accounts',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Account.fromMap(map)).toList();
  }

  Future<Account?> getAccountById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<String> createAccount(Account account) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final accountWithId = Account(
      id: id,
      name: account.name,
      type: account.type,
      currency: account.currency,
      balance: account.balance,
      icon: account.icon,
      color: account.color,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('accounts', accountWithId.toMap());
    return id;
  }

  Future<void> updateAccount(Account account) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'accounts',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateBalance(String accountId, double newBalance) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'accounts',
      {
        'balance': newBalance,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<double> getTotalBalance() async {
    final accounts = await getAllAccounts();
    return accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
  }
}
