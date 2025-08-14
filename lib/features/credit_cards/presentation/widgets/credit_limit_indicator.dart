import 'package:flutter/material.dart';

class CreditLimitIndicator extends StatelessWidget {
  final double totalLimit;
  final double usedAmount;
  final bool showLabel;

  const CreditLimitIndicator({
    super.key,
    required this.totalLimit,
    required this.usedAmount,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final utilizationPercentage =
        totalLimit > 0 ? (usedAmount / totalLimit).clamp(0.0, 1.0) : 0.0;
    final isOverLimit = usedAmount > totalLimit;
    final isNearLimit = utilizationPercentage >= 0.8;

    Color indicatorColor;
    if (isOverLimit) {
      indicatorColor = Colors.red;
    } else if (isNearLimit) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: utilizationPercentage,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₹${usedAmount.toStringAsFixed(0)} used',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'of ₹${totalLimit.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
