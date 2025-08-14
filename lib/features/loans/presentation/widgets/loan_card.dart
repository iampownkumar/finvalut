import 'package:flutter/material.dart';
import 'package:finvault/core/models/loan.dart';
import 'package:finvault/core/utils/currency_utils.dart';
import 'package:finvault/core/utils/date_utils.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPayment;

  const LoanCard({
    super.key,
    required this.loan,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final isGiven = loan.type == 'given';
    final color = isGiven ? Colors.green : Colors.blue;
    final isDueSoon = loan.isDueSoon;
    final isOverdue = loan.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isGiven ? Icons.trending_up : Icons.trending_down,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            isGiven ? 'Money Lent' : 'Money Borrowed',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'payment':
                            onPayment?.call();
                            break;
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (loan.remainingAmount > 0)
                          const PopupMenuItem(
                            value: 'payment',
                            child: Row(
                              children: [
                                Icon(Icons.payment,
                                    size: 18, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Record Payment'),
                              ],
                            ),
                          ),
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
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount Information
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountInfo(
                        'Total Amount',
                        CurrencyUtils.formatAmount(loan.amount),
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildAmountInfo(
                        'Remaining',
                        CurrencyUtils.formatAmount(loan.remainingAmount),
                        context,
                        color: loan.remainingAmount > 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${loan.completionPercentage.toStringAsFixed(1)}%',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: loan.completionPercentage / 100,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        loan.completionPercentage >= 100 ? Colors.green : color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Information
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo(
                        'Start Date',
                        AppDateUtils.formatShortDate(loan.startDate),
                        context,
                      ),
                    ),
                    Expanded(
                      child: _buildDateInfo(
                        'End Date',
                        AppDateUtils.formatShortDate(loan.endDate),
                        context,
                      ),
                    ),
                    if (loan.remainingAmount > 0)
                      Expanded(
                        child: _buildDateInfo(
                          'Remaining',
                          '${loan.remainingMonths} months',
                          context,
                          color: isDueSoon ? Colors.orange : null,
                        ),
                      ),
                  ],
                ),

                // Interest and Monthly Payment
                if (loan.interestRate > 0 || loan.monthlyPayment > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (loan.interestRate > 0)
                        Expanded(
                          child: _buildInfoChip(
                            '${loan.interestRate}% Interest',
                            Colors.orange,
                          ),
                        ),
                      if (loan.interestRate > 0 && loan.monthlyPayment > 0)
                        const SizedBox(width: 8),
                      if (loan.monthlyPayment > 0)
                        Expanded(
                          child: _buildInfoChip(
                            '₹${loan.monthlyPayment.toStringAsFixed(0)}/mo',
                            Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ],

                // Status Indicators
                if (isOverdue || isDueSoon || loan.remainingAmount == 0) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (isOverdue) _buildStatusChip('Overdue', Colors.red),
                      if (isDueSoon && !isOverdue)
                        _buildStatusChip('Due Soon', Colors.orange),
                      if (loan.remainingAmount == 0)
                        _buildStatusChip('Completed', Colors.green),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, String value, BuildContext context,
      {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, String value, BuildContext context,
      {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            text == 'Completed'
                ? Icons.check_circle
                : text == 'Overdue'
                    ? Icons.error
                    : Icons.warning,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
