import 'package:flutter/material.dart';
import 'package:finvault/core/models/credit_card.dart';
import 'package:finvault/core/services/credit_card_service.dart';
import 'package:finvault/features/credit_cards/presentation/widgets/credit_card_widget.dart';
import 'package:finvault/features/credit_cards/presentation/widgets/add_edit_credit_card_dialog.dart';
import 'package:finvault/features/credit_cards/presentation/widgets/credit_limit_indicator.dart';

class CreditCardsPage extends StatefulWidget {
  const CreditCardsPage({super.key});

  @override
  State<CreditCardsPage> createState() => _CreditCardsPageState();
}

class _CreditCardsPageState extends State<CreditCardsPage> {
  List<CreditCard> creditCards = [];
  Map<String, double> creditStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCreditCards();
  }

  Future<void> _loadCreditCards() async {
    setState(() => isLoading = true);
    try {
      final [cards, stats] = await Future.wait([
        CreditCardService.instance.getAllCreditCards(),
        CreditCardService.instance.getCreditCardStats(),
      ]);

      setState(() {
        creditCards = cards as List<CreditCard>;
        creditStats = stats as Map<String, double>;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading credit cards: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCreditCardDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : creditCards.isEmpty
              ? _buildEmptyState()
              : _buildCreditCardsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No credit cards yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first credit card to track spending',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCreditCardDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Credit Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardsList() {
    return RefreshIndicator(
      onRefresh: _loadCreditCards,
      child: Column(
        children: [
          // Credit Limit Overview
          if (creditStats.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Credit Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  CreditLimitIndicator(
                    totalLimit: creditStats['totalLimit'] ?? 0,
                    usedAmount: creditStats['totalUsed'] ?? 0,
                    showLabel: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsItem(
                          'Available',
                          '₹${(creditStats['availableLimit'] ?? 0).toStringAsFixed(0)}',
                          Colors.white,
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3)),
                      Expanded(
                        child: _buildStatsItem(
                          'Utilization',
                          '${(creditStats['utilizationPercentage'] ?? 0).toStringAsFixed(1)}%',
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Credit Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: creditCards.length,
              itemBuilder: (context, index) {
                return CreditCardWidget(
                  creditCard: creditCards[index],
                  onTap: () => _viewCardDetails(creditCards[index]),
                  onEdit: () => _showEditCreditCardDialog(creditCards[index]),
                  onDelete: () => _deleteCreditCard(creditCards[index]),
                );
              },
            ),
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

  void _showAddCreditCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditCreditCardDialog(
        onSave: (creditCard) async {
          await CreditCardService.instance.createCreditCard(creditCard);
          _loadCreditCards();
        },
      ),
    );
  }

  void _showEditCreditCardDialog(CreditCard creditCard) {
    showDialog(
      context: context,
      builder: (context) => AddEditCreditCardDialog(
        creditCard: creditCard,
        onSave: (updatedCard) async {
          await CreditCardService.instance.updateCreditCard(updatedCard);
          _loadCreditCards();
        },
      ),
    );
  }

  void _deleteCreditCard(CreditCard creditCard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Card'),
        content: Text(
            'Are you sure you want to delete "${creditCard.bankName} ${creditCard.cardNumber}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await CreditCardService.instance.deleteCreditCard(creditCard.id);
              _loadCreditCards();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${creditCard.bankName} card deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewCardDetails(CreditCard creditCard) {
    // TODO: Navigate to card details page in future
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Card details for ${creditCard.bankName} - Coming soon!')),
    );
  }
}
