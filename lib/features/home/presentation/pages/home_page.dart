import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finvault/core/models/account.dart';
import 'package:finvault/core/models/transaction.dart';
import 'package:finvault/core/services/account_service.dart';
import 'package:finvault/core/services/transaction_service.dart';
import 'package:finvault/features/transactions/presentation/pages/add_edit_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Account> accounts = [];
  List<Transaction> recentTransactions = [];
  Map<String, double> monthlyStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final [loadedAccounts, loadedTransactions, stats] = await Future.wait([
        AccountService.instance.getAllAccounts(),
        TransactionService.instance.getAllTransactions(limit: 5),
        TransactionService.instance.getMonthlyStats(),
      ]);

      setState(() {
        accounts = loadedAccounts as List<Account>;
        recentTransactions = loadedTransactions as List<Transaction>;
        monthlyStats = stats as Map<String, double>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceCard(accounts: accounts),
                    const SizedBox(height: 20),
                    _QuickStats(
                        stats: monthlyStats, accountCount: accounts.length),
                    const SizedBox(height: 20),
                    _QuickActions(),
                    const SizedBox(height: 20),
                    _RecentTransactions(
                      transactions: recentTransactions,
                      onRefresh: _loadData,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final List<Account> accounts;

  const _BalanceCard({required this.accounts});

  @override
  Widget build(BuildContext context) {
    final totalBalance =
        accounts.fold(0.0, (sum, account) => sum + account.balance);

    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${totalBalance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceItem(
                    label: 'Accounts',
                    value: '${accounts.length}',
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _BalanceItem(
                    label: 'Active',
                    value: '${accounts.where((a) => a.isActive).length}',
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickStats extends StatelessWidget {
  final Map<String, double> stats;
  final int accountCount;

  const _QuickStats({required this.stats, required this.accountCount});

  @override
  Widget build(BuildContext context) {
    final income = stats['income'] ?? 0;
    final expense = stats['expense'] ?? 0;
    final net = stats['net'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Month',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Income',
                amount: income,
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Expense',
                amount: expense,
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Net Income',
          amount: net,
          icon: net >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
          color: net >= 0 ? Colors.green : Colors.red,
          isWide: true,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '₹${amount.abs().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                title: 'Add Income',
                icon: Icons.add,
                color: Colors.green,
                onTap: () => _navigateToAddTransaction(context, 'income'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                title: 'Add Expense',
                icon: Icons.remove,
                color: Colors.red,
                onTap: () => _navigateToAddTransaction(context, 'expense'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToAddTransaction(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTransactionPage(),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onRefresh;

  const _RecentTransactions({
    required this.transactions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first transaction to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: transactions
                  .map((transaction) => _TransactionTile(
                        transaction: transaction,
                        onRefresh: onRefresh,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onRefresh;

  const _TransactionTile({
    required this.transaction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.categoryColor != null
        ? Color(int.parse(transaction.categoryColor!.replaceFirst('#', '0xFF')))
        : (transaction.type == 'expense' ? Colors.red : Colors.green);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          _getCategoryIcon(transaction.categoryIcon),
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description ?? transaction.categoryName ?? 'Transaction',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.categoryName} • ${_formatDate(transaction.date)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
      ),
      trailing: Text(
        '${transaction.type == 'expense' ? '-' : '+'}₹${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: transaction.type == 'expense' ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddEditTransactionPage(transaction: transaction),
          ),
        ).then((result) {
          if (result == true) onRefresh();
        });
      },
    );
  }

  IconData _getCategoryIcon(String? icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'work':
        return Icons.work;
      case 'movie':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
