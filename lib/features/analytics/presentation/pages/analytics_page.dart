import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/charts/animated_pie_chart.dart';
import '../../../../shared/widgets/charts/line_chart_widget.dart';
import '../../../../shared/widgets/charts/bar_chart_widget.dart';
import '../widgets/stats_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, double> categoryExpenses = {};
  Map<String, double> monthlyTrends = {};
  Map<String, dynamic> financialSummary = {};
  List<Map<String, dynamic>> dailyExpenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => isLoading = true);
    try {
      final [categories, trends, summary, daily] = await Future.wait([
        AnalyticsService.instance.getCategoryWiseExpenses(),
        AnalyticsService.instance.getMonthlyTrends(),
        AnalyticsService.instance.getFinancialSummary(),
        AnalyticsService.instance.getExpenseByDay(),
      ]);

      setState(() {
        categoryExpenses = categories as Map<String, double>;
        monthlyTrends = trends as Map<String, double>;
        financialSummary = summary as Map<String, dynamic>;
        dailyExpenses = daily as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
            Tab(text: 'Trends'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCategoriesTab(),
                _buildTrendsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (financialSummary.isEmpty) {
      return _buildEmptyState('No financial data available');
    }

    final thisMonth = financialSummary['thisMonth'] as Map<String, double>;
    final growth = financialSummary['growth'] as Map<String, double>;

    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Quick Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                StatsCard(
                  title: 'This Month Income',
                  value: CurrencyUtils.formatAmount(thisMonth['income'] ?? 0),
                  icon: Icons.trending_up,
                  color: Colors.green,
                  growth: growth['income'],
                ),
                StatsCard(
                  title: 'This Month Expense',
                  value: CurrencyUtils.formatAmount(thisMonth['expense'] ?? 0),
                  icon: Icons.trending_down,
                  color: Colors.red,
                  growth: growth['expense'],
                ),
                StatsCard(
                  title: 'Net Income',
                  value: CurrencyUtils.formatAmount(thisMonth['net'] ?? 0),
                  icon: Icons.account_balance_wallet,
                  color:
                      (thisMonth['net'] ?? 0) >= 0 ? Colors.green : Colors.red,
                ),
                StatsCard(
                  title: 'Average Daily Expense',
                  value: CurrencyUtils.formatAmount(_getAverageDailyExpense()),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Daily Expense Trend
            if (dailyExpenses.isNotEmpty) ...[
              Text(
                'Daily Expenses (Last 30 Days)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDailyExpenseChart(),
              const SizedBox(height: 24),
            ],

            // Top Categories
            if (financialSummary['topCategories'] != null) ...[
              Text(
                'Top Spending Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildTopCategoriesList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (categoryExpenses.isEmpty) {
      return _buildEmptyState('No category data available');
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedPieChart(
              data: categoryExpenses,
              title: 'Expenses by Category',
              size: 250,
            ),
            const SizedBox(height: 24),
            BarChartWidget(
              data: categoryExpenses,
              title: 'Category Breakdown',
              height: 300,
              barColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (monthlyTrends.isEmpty) {
      return _buildEmptyState('No trend data available');
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthlyTrendChart(),
            const SizedBox(height: 24),
            _buildTrendAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExpenseChart() {
    final spots = dailyExpenses.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['amount']);
    }).toList();

    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendChart() {
    final months = AppDateUtils.getLast6Months();
    final incomeData = <FlSpot>[];
    final expenseData = <FlSpot>[];
    final xLabels = <String>[];

    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      incomeData
          .add(FlSpot(i.toDouble(), monthlyTrends['${monthKey}_income'] ?? 0));
      expenseData
          .add(FlSpot(i.toDouble(), monthlyTrends['${monthKey}_expense'] ?? 0));
      xLabels.add(AppDateUtils.getMonthName(month.month));
    }

    return LineChartWidget(
      incomeData: incomeData,
      expenseData: expenseData,
      xLabels: xLabels,
      title: 'Monthly Income vs Expense Trend',
      height: 300,
    );
  }

  Widget _buildTopCategoriesList() {
    final topCategories = financialSummary['topCategories'] as List<dynamic>;

    return Column(
      children: topCategories.take(5).map((category) {
        final name = category['name'] as String;
        final amount = category['amount'] as double;
        final total =
            categoryExpenses.values.fold(0.0, (sum, value) => sum + value);
        final percentage = total > 0 ? (amount / total) * 100 : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(name),
              subtitle:
                  Text('${percentage.toStringAsFixed(1)}% of total expenses'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.formatAmount(amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTrendInsight('Best Month', _getBestMonth()),
            const SizedBox(height: 8),
            _buildTrendInsight(
                'Highest Expense Month', _getHighestExpenseMonth()),
            const SizedBox(height: 8),
            _buildTrendInsight('Average Monthly Expense',
                CurrencyUtils.formatAmount(_getAverageMonthlyExpense())),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendInsight(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  double _getAverageDailyExpense() {
    if (dailyExpenses.isEmpty) return 0;
    final total = dailyExpenses.fold(0.0, (sum, day) => sum + day['amount']);
    return total / dailyExpenses.length;
  }

  String _getBestMonth() {
    // Month with highest net income
    final months = AppDateUtils.getLast6Months();
    double bestNet = double.negativeInfinity;
    String bestMonth = 'N/A';

    for (final month in months) {
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final income = monthlyTrends['${monthKey}_income'] ?? 0;
      final expense = monthlyTrends['${monthKey}_expense'] ?? 0;
      final net = income - expense;

      if (net > bestNet) {
        bestNet = net;
        bestMonth = AppDateUtils.formatMonthYear(month);
      }
    }

    return bestMonth;
  }

  String _getHighestExpenseMonth() {
    final months = AppDateUtils.getLast6Months();
    double highestExpense = 0;
    String highestMonth = 'N/A';

    for (final month in months) {
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final expense = monthlyTrends['${monthKey}_expense'] ?? 0;

      if (expense > highestExpense) {
        highestExpense = expense;
        highestMonth = AppDateUtils.formatMonthYear(month);
      }
    }

    return highestMonth;
  }

  double _getAverageMonthlyExpense() {
    final months = AppDateUtils.getLast6Months();
    double total = 0;
    int count = 0;

    for (final month in months) {
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final expense = monthlyTrends['${monthKey}_expense'] ?? 0;
      if (expense > 0) {
        total += expense;
        count++;
      }
    }

    return count > 0 ? total / count : 0;
  }
}
