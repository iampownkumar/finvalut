import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._init();
  AnalyticsService._init();

  Future<Map<String, double>> getCategoryWiseExpenses(
      {DateTime? startDate, DateTime? endDate}) async {
    final db = await DatabaseHelper.instance.database;

    String query = '''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE t.type = 'expense'
    ''';

    List<dynamic> args = [];

    if (startDate != null) {
      query += ' AND t.date >= ?';
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      query += ' AND t.date <= ?';
      args.add(endDate.toIso8601String());
    }

    query += ' GROUP BY c.name ORDER BY total DESC';

    final result = await db.rawQuery(query, args);

    Map<String, double> categoryExpenses = {};
    for (final row in result) {
      final categoryName = row['name'] as String? ?? 'Unknown';
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      categoryExpenses[categoryName] = total;
    }

    return categoryExpenses;
  }

  Future<Map<String, double>> getMonthlyTrends({int months = 6}) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, 1);

    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', t.date) as month,
        t.type,
        SUM(t.amount) as total
      FROM transactions t
      WHERE t.date >= ?
      GROUP BY month, t.type
      ORDER BY month
    ''', [startDate.toIso8601String()]);

    Map<String, double> monthlyIncome = {};
    Map<String, double> monthlyExpense = {};

    for (final row in result) {
      final month = row['month'] as String;
      final type = row['type'] as String;
      final total = (row['total'] as num).toDouble();

      if (type == 'income') {
        monthlyIncome[month] = total;
      } else {
        monthlyExpense[month] = total;
      }
    }

    // Ensure all months have entries (fill with 0 if no data)
    Map<String, double> trends = {};
    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      trends['${monthKey}_income'] = monthlyIncome[monthKey] ?? 0.0;
      trends['${monthKey}_expense'] = monthlyExpense[monthKey] ?? 0.0;
    }

    return trends;
  }

  Future<Map<String, dynamic>> getFinancialSummary() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    // This month
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthStats = await TransactionService.instance.getMonthlyStats();

    // Last month
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    final lastMonthResult = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE date >= ? AND date <= ?
      GROUP BY type
    ''', [lastMonthStart.toIso8601String(), lastMonthEnd.toIso8601String()]);

    double lastMonthIncome = 0;
    double lastMonthExpense = 0;

    for (final row in lastMonthResult) {
      if (row['type'] == 'income') {
        lastMonthIncome = (row['total'] as num).toDouble();
      } else if (row['type'] == 'expense') {
        lastMonthExpense = (row['total'] as num).toDouble();
      }
    }

    // Calculate growth
    final incomeGrowth = lastMonthIncome > 0
        ? ((thisMonthStats['income']! - lastMonthIncome) / lastMonthIncome) *
            100
        : 0.0;

    final expenseGrowth = lastMonthExpense > 0
        ? ((thisMonthStats['expense']! - lastMonthExpense) / lastMonthExpense) *
            100
        : 0.0;

    // Top categories this month
    final topCategories =
        await getCategoryWiseExpenses(startDate: thisMonthStart);
    final sortedCategories = topCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'thisMonth': thisMonthStats,
      'lastMonth': {
        'income': lastMonthIncome,
        'expense': lastMonthExpense,
        'net': lastMonthIncome - lastMonthExpense,
      },
      'growth': {
        'income': incomeGrowth,
        'expense': expenseGrowth,
      },
      'topCategories': sortedCategories
          .take(5)
          .map((e) => {
                'name': e.key,
                'amount': e.value,
              })
          .toList(),
    };
  }

  Future<List<Map<String, dynamic>>> getExpenseByDay({int days = 30}) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final result = await db.rawQuery('''
      SELECT 
        DATE(t.date) as date,
        SUM(t.amount) as total
      FROM transactions t
      WHERE t.type = 'expense' AND t.date >= ?
      GROUP BY DATE(t.date)
      ORDER BY date
    ''', [startDate.toIso8601String()]);

    return result
        .map((row) => {
              'date': row['date'] as String,
              'amount': (row['total'] as num).toDouble(),
            })
        .toList();
  }

  Future<double> getAverageMonthlyExpense({int months = 6}) async {
    final monthlyTrends = await getMonthlyTrends(months: months);
    final expenses = monthlyTrends.entries
        .where((entry) => entry.key.endsWith('_expense'))
        .map((entry) => entry.value)
        .toList();

    if (expenses.isEmpty) return 0.0;
    return expenses.reduce((a, b) => a + b) / expenses.length;
  }
}
