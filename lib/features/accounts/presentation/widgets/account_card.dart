import 'package:flutter/material.dart';
import 'package:finvault/core/models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = account.color != null
        ? Color(int.parse(account.color!.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Account Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAccountIcon(account.icon, account.type),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Account Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getAccountTypeLabel(account.type)} • ${account.currency}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),

              // Balance & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${account.balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              account.balance >= 0 ? Colors.green : Colors.red,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (onDelete != null)
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(String? icon, String type) {
    if (icon != null) {
      switch (icon) {
        case 'wallet':
          return Icons.account_balance_wallet;
        case 'bank':
          return Icons.account_balance;
        case 'card':
          return Icons.credit_card;
        case 'cash':
          return Icons.money;
        case 'savings':
          return Icons.savings;
        default:
          return Icons.account_balance_wallet;
      }
    }

    switch (type) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank Account';
      case 'card':
        return 'Card';
      case 'savings':
        return 'Savings';
      default:
        return type.toUpperCase();
    }
  }
}
