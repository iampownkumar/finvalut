import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finvault/core/models/loan.dart';

class AddEditLoanDialog extends StatefulWidget {
  final Loan? loan;
  final String? initialType;
  final Function(Loan) onSave;

  const AddEditLoanDialog({
    super.key,
    this.loan,
    this.initialType,
    required this.onSave,
  });

  @override
  State<AddEditLoanDialog> createState() => _AddEditLoanDialogState();
}

class _AddEditLoanDialogState extends State<AddEditLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _remainingAmountController = TextEditingController();

  String _selectedType = 'taken';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _initializeWithLoan();
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  void _initializeWithLoan() {
    final loan = widget.loan!;
    _titleController.text = loan.title;
    _amountController.text = loan.amount.toString();
    _interestRateController.text = loan.interestRate.toString();
    _monthlyPaymentController.text = loan.monthlyPayment.toString();
    _remainingAmountController.text = loan.remainingAmount.toString();
    _selectedType = loan.type;
    _startDate = loan.startDate;
    _endDate = loan.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.loan == null ? 'Add Loan' : 'Edit Loan',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Loan Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Loan Title',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter loan title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Loan Type
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Loan Type',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTypeButton(
                                      'given',
                                      'Money Given',
                                      Icons.trending_up,
                                      Colors.green),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTypeButton(
                                      'taken',
                                      'Money Taken',
                                      Icons.trending_down,
                                      Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Amount and Remaining Amount
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _amountController,
                                decoration: const InputDecoration(
                                  labelText: 'Total Amount',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid amount';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  // Auto-set remaining amount if not editing
                                  if (widget.loan == null && value.isNotEmpty) {
                                    _remainingAmountController.text = value;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _remainingAmountController,
                                decoration: const InputDecoration(
                                  labelText: 'Remaining Amount',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter remaining';
                                  }
                                  final remaining = double.tryParse(value);
                                  final total =
                                      double.tryParse(_amountController.text);
                                  if (remaining == null) {
                                    return 'Invalid amount';
                                  }
                                  if (total != null && remaining > total) {
                                    return 'Cannot exceed total';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Interest Rate and Monthly Payment
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _interestRateController,
                                decoration: const InputDecoration(
                                  labelText: 'Interest Rate (Optional)',
                                  border: OutlineInputBorder(),
                                  suffixText: '%',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _monthlyPaymentController,
                                decoration: const InputDecoration(
                                  labelText: 'Monthly Payment (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Start Date and End Date
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _selectStartDate(),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today),
                                          const SizedBox(width: 12),
                                          Text(DateFormat('MMM dd, yyyy')
                                              .format(_startDate)),
                                        ],
                                      ),
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
                                    'End Date',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _selectEndDate(),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today),
                                          const SizedBox(width: 12),
                                          Text(DateFormat('MMM dd, yyyy')
                                              .format(_endDate)),
                                        ],
                                      ),
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
                      onPressed: _saveLoan,
                      child: Text(widget.loan == null ? 'Add' : 'Save'),
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

  Widget _buildTypeButton(
      String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _saveLoan() {
    if (_formKey.currentState!.validate()) {
      final loan = Loan(
        id: widget.loan?.id ?? '',
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        interestRate: double.tryParse(_interestRateController.text) ?? 0.0,
        startDate: _startDate,
        endDate: _endDate,
        monthlyPayment: double.tryParse(_monthlyPaymentController.text) ?? 0.0,
        remainingAmount: double.parse(_remainingAmountController.text),
        isActive: true,
        createdAt: widget.loan?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(loan);
      Navigator.pop(context);
    }
  }
}
