import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  // Future _createDB(Database db, int version) async {
  //   const idType = 'TEXT PRIMARY KEY';
  //   const textType = 'TEXT NOT NULL';
  //   const textTypeNullable = 'TEXT';
  //   const integerType = 'INTEGER NOT NULL';
  //   const realType = 'REAL NOT NULL';
  //   const boolType = 'INTEGER NOT NULL';

  //   // Accounts table
  //   await db.execute('''
  //   CREATE TABLE accounts (
  //     id $idType,
  //     name $textType,
  //     type $textType,
  //     currency $textType,
  //     balance $realType,
  //     icon $textTypeNullable,
  //     color $textTypeNullable,
  //     isActive $boolType,
  //     createdAt $textType,
  //     updatedAt $textType
  //   )
  // ''');

  //   // Categories table
  //   await db.execute('''
  //   CREATE TABLE categories (
  //     id $idType,
  //     name $textType,
  //     type $textType,
  //     icon $textTypeNullable,
  //     color $textTypeNullable,
  //     isActive $boolType,
  //     createdAt $textType,
  //     updatedAt $textType
  //   )
  // ''');

  //   // Transactions table
  //   await db.execute('''
  //   CREATE TABLE transactions (
  //     id $idType,
  //     accountId $textType,
  //     categoryId $textType,
  //     amount $realType,
  //     type $textType,
  //     description $textTypeNullable,
  //     date $textType,
  //     createdAt $textType,
  //     updatedAt $textType,
  //     FOREIGN KEY (accountId) REFERENCES accounts (id),
  //     FOREIGN KEY (categoryId) REFERENCES categories (id)
  //   )
  // ''');

  //   // Credit Cards table
  //   await db.execute('''
  //   CREATE TABLE credit_cards (
  //     id $idType,
  //     bankName $textType,
  //     cardNumber $textType,
  //     cardLimit $realType,
  //     usedAmount $realType,
  //     billDate $integerType,
  //     paymentDate $integerType,
  //     isActive $boolType,
  //     createdAt $textType,
  //     updatedAt $textType
  //   )
  // ''');

  //   // Loans table
  //   await db.execute('''
  //   CREATE TABLE loans (
  //     id $idType,
  //     title $textType,
  //     amount $realType,
  //     type $textType,
  //     interestRate $realType,
  //     startDate $textType,
  //     endDate $textType,
  //     monthlyPayment $realType,
  //     remainingAmount $realType,
  //     isActive $boolType,
  //     createdAt $textType,
  //     updatedAt $textType
  //   )
  // ''');

  //   // Insert sample data
  //   await _insertSampleData(db);
  // }

  // Find the _createDB method and modify it like this:

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

    // Insert only essential categories - no sample transactions/accounts
    await _insertEssentialCategories(db);
  }

  Future<void> _insertEssentialCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Essential expense categories
    final expenseCategories = [
      {
        'id': 'cat_food',
        'name': 'Food & Dining',
        'type': 'expense',
        'icon': 'restaurant',
        'color': '#EF4444'
      },
      {
        'id': 'cat_transport',
        'name': 'Transportation',
        'type': 'expense',
        'icon': 'directions_car',
        'color': '#F59E0B'
      },
      {
        'id': 'cat_shopping',
        'name': 'Shopping',
        'type': 'expense',
        'icon': 'shopping_bag',
        'color': '#8B5CF6'
      },
      {
        'id': 'cat_entertainment',
        'name': 'Entertainment',
        'type': 'expense',
        'icon': 'movie',
        'color': '#F97316'
      },
      {
        'id': 'cat_healthcare',
        'name': 'Healthcare',
        'type': 'expense',
        'icon': 'health',
        'color': '#EC4899'
      },
      {
        'id': 'cat_utilities',
        'name': 'Bills & Utilities',
        'type': 'expense',
        'icon': 'receipt',
        'color': '#6B7280'
      },
    ];

    // Essential income categories
    final incomeCategories = [
      {
        'id': 'cat_salary',
        'name': 'Salary',
        'type': 'income',
        'icon': 'work',
        'color': '#10B981'
      },
      {
        'id': 'cat_freelance',
        'name': 'Freelance',
        'type': 'income',
        'icon': 'work',
        'color': '#059669'
      },
      {
        'id': 'cat_investment',
        'name': 'Investment',
        'type': 'income',
        'icon': 'trending_up',
        'color': '#0D9488'
      },
      {
        'id': 'cat_other_income',
        'name': 'Other Income',
        'type': 'income',
        'icon': 'attach_money',
        'color': '#16A34A'
      },
    ];

    // Insert categories
    for (final category in [...expenseCategories, ...incomeCategories]) {
      await db.insert('categories', {
        ...category,
        'isActive': 1,
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

// COMMENT OUT OR REMOVE the old _insertSampleData method entirely
/*
Future<void> _insertSampleData(Database db) async {
  // This method is removed for production build
  // Users will start with clean data
}
*/

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
      {
        'id': 'cat_6',
        'name': 'Healthcare',
        'type': 'expense',
        'icon': 'health',
        'color': '#EC4899'
      },
      {
        'id': 'cat_7',
        'name': 'Freelance',
        'type': 'income',
        'icon': 'work',
        'color': '#059669'
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

    // Sample transactions with more variety
    final sampleTransactions = [
      {
        'id': 'txn_1',
        'accountId': 'acc_1',
        'categoryId': 'cat_1',
        'amount': 450.0,
        'type': 'expense',
        'description': 'Lunch at restaurant',
        'daysAgo': 1
      },
      {
        'id': 'txn_2',
        'accountId': 'acc_2',
        'categoryId': 'cat_4',
        'amount': 75000.0,
        'type': 'income',
        'description': 'Monthly salary',
        'daysAgo': 5
      },
      {
        'id': 'txn_3',
        'accountId': 'acc_1',
        'categoryId': 'cat_2',
        'amount': 200.0,
        'type': 'expense',
        'description': 'Uber ride',
        'daysAgo': 3
      },
      {
        'id': 'txn_4',
        'accountId': 'acc_2',
        'categoryId': 'cat_3',
        'amount': 2500.0,
        'type': 'expense',
        'description': 'Clothes shopping',
        'daysAgo': 7
      },
      {
        'id': 'txn_5',
        'accountId': 'acc_1',
        'categoryId': 'cat_7',
        'amount': 15000.0,
        'type': 'income',
        'description': 'Freelance project',
        'daysAgo': 10
      },
      {
        'id': 'txn_6',
        'accountId': 'acc_1',
        'categoryId': 'cat_5',
        'amount': 800.0,
        'type': 'expense',
        'description': 'Movie tickets',
        'daysAgo': 2
      },
      {
        'id': 'txn_7',
        'accountId': 'acc_2',
        'categoryId': 'cat_6',
        'amount': 1200.0,
        'type': 'expense',
        'description': 'Doctor visit',
        'daysAgo': 12
      },
    ];

    for (final txn in sampleTransactions) {
      await db.insert('transactions', {
        'id': txn['id'],
        'accountId': txn['accountId'],
        'categoryId': txn['categoryId'],
        'amount': txn['amount'],
        'type': txn['type'],
        'description': txn['description'],
        'date': DateTime.now()
            .subtract(Duration(days: txn['daysAgo'] as int))
            .toIso8601String(),
        'createdAt': now,
        'updatedAt': now,
      });
    }

    // Sample credit cards
    await db.insert('credit_cards', {
      'id': 'cc_1',
      'bankName': 'HDFC Bank',
      'cardNumber': '****1234',
      'cardLimit': 50000.0,
      'usedAmount': 15000.0,
      'billDate': 5,
      'paymentDate': 25,
      'isActive': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('credit_cards', {
      'id': 'cc_2',
      'bankName': 'SBI Card',
      'cardNumber': '****5678',
      'cardLimit': 80000.0,
      'usedAmount': 32000.0,
      'billDate': 15,
      'paymentDate': 10,
      'isActive': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    // Sample loans
    await db.insert('loans', {
      'id': 'loan_1',
      'title': 'Personal Loan',
      'amount': 200000.0,
      'type': 'taken',
      'interestRate': 12.5,
      'startDate':
          DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
      'endDate': DateTime.now()
          .add(const Duration(days: 1285))
          .toIso8601String(), // ~3.5 years from start
      'monthlyPayment': 6500.0,
      'remainingAmount': 160000.0,
      'isActive': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.insert('loans', {
      'id': 'loan_2',
      'title': 'Loan to Friend',
      'amount': 50000.0,
      'type': 'given',
      'interestRate': 0.0,
      'startDate':
          DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'endDate': DateTime.now()
          .add(const Duration(days: 305))
          .toIso8601String(), // ~1 year from start
      'monthlyPayment': 5000.0,
      'remainingAmount': 40000.0,
      'isActive': 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
