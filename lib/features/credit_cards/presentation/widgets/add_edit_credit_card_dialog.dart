import 'package:flutter/material.dart';
import 'package:finvault/core/models/credit_card.dart';

class AddEditCreditCardDialog extends StatefulWidget {
  final CreditCard? creditCard;
  final Function(CreditCard) onSave;

  const AddEditCreditCardDialog({
    super.key,
    this.creditCard,
    required this.onSave,
  });

  @override
  State<AddEditCreditCardDialog> createState() =>
      _AddEditCreditCardDialogState();
}

class _AddEditCreditCardDialogState extends State<AddEditCreditCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardLimitController = TextEditingController();
  final _usedAmountController = TextEditingController();

  int _billDate = 1;
  int _paymentDate = 20;

  @override
  void initState() {
    super.initState();
    if (widget.creditCard != null) {
      _bankNameController.text = widget.creditCard!.bankName;
      _cardNumberController.text = widget.creditCard!.cardNumber;
      _cardLimitController.text = widget.creditCard!.cardLimit.toString();
      _usedAmountController.text = widget.creditCard!.usedAmount.toString();
      _billDate = widget.creditCard!.billDate;
      _paymentDate = widget.creditCard!.paymentDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.creditCard == null
                      ? 'Add Credit Card'
                      : 'Edit Credit Card',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Bank Name
                        TextFormField(
                          controller: _bankNameController,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter bank name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Card Number (last 4 digits)
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Card Number (Last 4 digits)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.credit_card),
                            prefixText: '****',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter last 4 digits';
                            }
                            if (value.length != 4) {
                              return 'Please enter exactly 4 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Card Limit and Used Amount
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cardLimitController,
                                decoration: const InputDecoration(
                                  labelText: 'Credit Limit',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter limit';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid amount';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _usedAmountController,
                                decoration: const InputDecoration(
                                  labelText: 'Used Amount',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter used amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid amount';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Bill Date
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bill Date',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _billDate,
                                      isExpanded: true,
                                      underline: const SizedBox.shrink(),
                                      items: List.generate(31, (index) {
                                        final day = index + 1;
                                        return DropdownMenuItem(
                                          value: day,
                                          child: Text(
                                              '${day}${_getDateSuffix(day)}'),
                                        );
                                      }),
                                      onChanged: (value) {
                                        setState(() => _billDate = value!);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Date',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _paymentDate,
                                      isExpanded: true,
                                      underline: const SizedBox.shrink(),
                                      items: List.generate(31, (index) {
                                        final day = index + 1;
                                        return DropdownMenuItem(
                                          value: day,
                                          child: Text(
                                              '${day}${_getDateSuffix(day)}'),
                                        );
                                      }),
                                      onChanged: (value) {
                                        setState(() => _paymentDate = value!);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveCreditCard,
                      child: Text(widget.creditCard == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCreditCard() {
    if (_formKey.currentState!.validate()) {
      final creditCard = CreditCard(
        id: widget.creditCard?.id ?? '',
        bankName: _bankNameController.text.trim(),
        cardNumber: '****${_cardNumberController.text}',
        cardLimit: double.parse(_cardLimitController.text),
        usedAmount: double.parse(_usedAmountController.text),
        billDate: _billDate,
        paymentDate: _paymentDate,
        isActive: true,
        createdAt: widget.creditCard?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(creditCard);
      Navigator.pop(context);
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
