import 'package:flutter/material.dart';
import 'package:finvault/core/models/credit_card.dart';
import 'credit_limit_indicator.dart';

class CreditCardWidget extends StatelessWidget {
  final CreditCard creditCard;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CreditCardWidget({
    super.key,
    required this.creditCard,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getCardGradient(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with bank name and actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creditCard.bankName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          creditCard.cardNumber,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Credit limit information
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Credit',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₹${creditCard.availableLimit.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Utilization',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${creditCard.utilizationPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: creditCard.isNearLimit
                                ? Colors.orange
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Credit limit indicator
              CreditLimitIndicator(
                totalLimit: creditCard.cardLimit,
                usedAmount: creditCard.usedAmount,
                showLabel: false,
              ),
              const SizedBox(height: 12),

              // Bill and payment dates
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo('Bill Date',
                        '${creditCard.billDate}${_getDateSuffix(creditCard.billDate)}'),
                  ),
                  Expanded(
                    child: _buildDateInfo('Pay Date',
                        '${creditCard.paymentDate}${_getDateSuffix(creditCard.paymentDate)}'),
                  ),
                ],
              ),

              // Warning indicators
              if (creditCard.isOverLimit || creditCard.isNearLimit) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: creditCard.isOverLimit
                        ? Colors.red.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          creditCard.isOverLimit ? Colors.red : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        creditCard.isOverLimit ? Icons.error : Icons.warning,
                        size: 16,
                        color:
                            creditCard.isOverLimit ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        creditCard.isOverLimit ? 'Over Limit!' : 'Near Limit',
                        style: TextStyle(
                          color: creditCard.isOverLimit
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String value) {
    return Column(
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Color> _getCardGradient() {
    // Different gradients for different card types based on bank
    final bank = creditCard.bankName.toLowerCase();
    if (bank.contains('hdfc')) {
      return [const Color(0xFF1565C0), const Color(0xFF1976D2)];
    } else if (bank.contains('sbi')) {
      return [const Color(0xFF2E7D32), const Color(0xFF388E3C)];
    } else if (bank.contains('icici')) {
      return [const Color(0xFFD32F2F), const Color(0xFFE53935)];
    } else {
      return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  String _getDateSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
