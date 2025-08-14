import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finvault/core/models/transaction.dart';
import 'package:finvault/core/services/transaction_service.dart';
import 'package:finvault/core/utils/currency_utils.dart';
import 'package:finvault/core/utils/date_utils.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String selectedFilter = 'all'; // all, income, expense

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);
    try {
      final loadedTransactions =
          await TransactionService.instance.getAllTransactions();
      setState(() {
        transactions = loadedTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  List<Transaction> get filteredTransactions {
    if (selectedFilter == 'all') return transactions;
    return transactions.where((t) => t.type == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/transaction/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Income', 'income'),
                const SizedBox(width: 8),
                _buildFilterChip('Expense', 'expense'),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return _buildTransactionTile(transaction);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => selectedFilter = value);
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final color = transaction.categoryColor != null
        ? Color(int.parse(transaction.categoryColor!.replaceFirst('#', '0xFF')))
        : (transaction.type == 'expense' ? Colors.red : Colors.green);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.categoryName ?? 'Unknown Category'),
            Text(
              AppDateUtils.formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
        trailing: Text(
          '${transaction.type == 'expense' ? '-' : '+'}${CurrencyUtils.formatAmount(transaction.amount)}',
          style: TextStyle(
            color: transaction.type == 'expense' ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          context.go('/transaction/edit/${transaction.id}');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            selectedFilter == 'all'
                ? 'Add your first transaction to get started'
                : 'No ${selectedFilter} transactions found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/transaction/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
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
}
