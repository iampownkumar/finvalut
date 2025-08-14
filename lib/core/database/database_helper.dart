import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finvault.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id $idType,
        name $textType,
        type $textType,
        currency $textType,
        balance $realType,
        icon $textTypeNullable,
        color $textTypeNullable,
        isActive $boolType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        type $textType,
        icon $textTypeNullable,
        color $textTypeNullable,
        isActive $boolType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        accountId $textType,
        categoryId $textType,
        amount $realType,
        type $textType,
        description $textTypeNullable,
        date $textType,
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (accountId) REFERENCES accounts (id),
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Credit Cards table
    await db.execute('''
      CREATE TABLE credit_cards (
        id $idType,
        bankName $textType,
        cardNumber $textType,
        cardLimit $realType,
        usedAmount $realType,
        billDate $integerType,
        paymentDate $integerType,
        isActive $boolType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Loans table
    await db.execute('''
      CREATE TABLE loans (
        id $idType,
        title $textType,
        amount $realType,
        type $textType,
        interestRate $realType,
        startDate $textType,
        endDate $textType,
        monthlyPayment $realType,
        remainingAmount $realType,
        isActive $boolType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Sample accounts
    await db.insert('accounts', {
      'id': 'acc_1',
      'name': 'Main Wallet',
      'type': 'cash',
      'currency': 'INR',
      'balance': 25000.0,
      'icon': 'wallet',
      'color': '#6366F1',
      'isActive': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('accounts', {
      'id': 'acc_2',
      'name': 'HDFC Savings',
      'type': 'bank',
      'currency': 'INR',
      'balance': 150000.0,
      'icon': 'bank',
      'color': '#10B981',
      'isActive': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    // Sample categories
    final categories = [
      {
        'id': 'cat_1',
        'name': 'Food & Dining',
        'type': 'expense',
        'icon': 'restaurant',
        'color': '#EF4444'
      },
      {
        'id': 'cat_2',
        'name': 'Transportation',
        'type': 'expense',
        'icon': 'directions_car',
        'color': '#F59E0B'
      },
      {
        'id': 'cat_3',
        'name': 'Shopping',
        'type': 'expense',
        'icon': 'shopping_bag',
        'color': '#8B5CF6'
      },
      {
        'id': 'cat_4',
        'name': 'Salary',
        'type': 'income',
        'icon': 'work',
        'color': '#10B981'
      },
      {
        'id': 'cat_5',
        'name': 'Entertainment',
        'type': 'expense',
        'icon': 'movie',
        'color': '#F97316'
      },
    ];

    for (final category in categories) {
      await db.insert('categories', {
        ...category,
        'isActive': 1,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    // Sample transactions
    await db.insert('transactions', {
      'id': 'txn_1',
      'accountId': 'acc_1',
      'categoryId': 'cat_1',
      'amount': 450.0,
      'type': 'expense',
      'description': 'Lunch at restaurant',
      'date':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('transactions', {
      'id': 'txn_2',
      'accountId': 'acc_2',
      'categoryId': 'cat_4',
      'amount': 75000.0,
      'type': 'income',
      'description': 'Monthly salary',
      'date':
          DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
