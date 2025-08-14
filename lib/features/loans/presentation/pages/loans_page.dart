import 'package:flutter/material.dart';
import 'package:finvault/core/models/loan.dart';
import 'package:finvault/core/services/loan_service.dart';
import 'package:finvault/features/loans/presentation/widgets/loan_card.dart';
import 'package:finvault/features/loans/presentation/widgets/add_edit_loan_dialog.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Loan> givenLoans = [];
  List<Loan> takenLoans = [];
  Map<String, double> loanStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => isLoading = true);
    try {
      final [given, taken, stats] = await Future.wait([
        LoanService.instance.getLoansByType('given'),
        LoanService.instance.getLoansByType('taken'),
        LoanService.instance.getLoanStats(),
      ]);

      setState(() {
        givenLoans = given as List<Loan>;
        takenLoans = taken as List<Loan>;
        loanStats = stats as Map<String, double>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading loans: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Given (${givenLoans.length})'),
            Tab(text: 'Taken (${takenLoans.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLoanDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Loan Stats Overview
                if (loanStats.isNotEmpty) _buildLoanStatsOverview(),

                // Loans Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoansTab(givenLoans, 'given'),
                      _buildLoansTab(takenLoans, 'taken'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoanStatsOverview() {
    final netPosition = loanStats['netLoanPosition'] ?? 0;
    final isPositive = netPosition >= 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isPositive ? Colors.green : Colors.red,
            (isPositive ? Colors.green : Colors.red).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Net Loan Position',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${netPosition.abs().toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            isPositive ? 'You will receive' : 'You owe',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatsItem(
                  'Lent Out',
                  '₹${(loanStats['totalRemainingLent'] ?? 0).toStringAsFixed(0)}',
                  Colors.white,
                ),
              ),
              Container(
                  width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatsItem(
                  'Borrowed',
                  '₹${(loanStats['totalRemainingBorrowed'] ?? 0).toStringAsFixed(0)}',
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoansTab(List<Loan> loans, String type) {
    if (loans.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          return LoanCard(
            loan: loans[index],
            onTap: () => _viewLoanDetails(loans[index]),
            onEdit: () => _showEditLoanDialog(loans[index]),
            onDelete: () => _deleteLoan(loans[index]),
            onPayment: () => _makePayment(loans[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'given' ? Icons.trending_up : Icons.trending_down,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type == 'given' ? 'loans given' : 'loans taken'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            type == 'given'
                ? 'Track money you\'ve lent to others'
                : 'Track money you\'ve borrowed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLoanDialog(type),
            icon: const Icon(Icons.add),
            label: Text('Add ${type == 'given' ? 'Loan Given' : 'Loan Taken'}'),
          ),
        ],
      ),
    );
  }

  void _showAddLoanDialog([String? type]) {
    showDialog(
      context: context,
      builder: (context) => AddEditLoanDialog(
        initialType: type ?? (_tabController.index == 0 ? 'given' : 'taken'),
        onSave: (loan) async {
          await LoanService.instance.createLoan(loan);
          _loadLoans();
        },
      ),
    );
  }

  void _showEditLoanDialog(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AddEditLoanDialog(
        loan: loan,
        onSave: (updatedLoan) async {
          await LoanService.instance.updateLoan(updatedLoan);
          _loadLoans();
        },
      ),
    );
  }

  void _deleteLoan(Loan loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: Text('Are you sure you want to delete "${loan.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LoanService.instance.deleteLoan(loan.id);
              _loadLoans();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${loan.title} deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _makePayment(Loan loan) {
    final paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make Payment - ${loan.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Remaining Amount: ₹${loan.remainingAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: paymentController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(paymentController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                await LoanService.instance.makePayment(loan.id, amount);
                _loadLoans();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Payment of ₹${amount.toStringAsFixed(2)} recorded')),
                  );
                }
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _viewLoanDetails(Loan loan) {
    // TODO: Navigate to loan details page in future
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loan details for ${loan.title} - Coming soon!')),
    );
  }
}
