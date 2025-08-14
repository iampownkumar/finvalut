import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:finvault/core/models/transaction.dart';
import 'package:finvault/core/models/account.dart';
import 'package:finvault/core/models/category.dart';
import 'package:finvault/core/services/transaction_service.dart';
import 'package:finvault/core/services/account_service.dart';
import 'package:finvault/core/services/category_service.dart';
import 'package:finvault/core/utils/currency_utils.dart';

class AddEditTransactionPage extends StatefulWidget {
  final Transaction? transaction;
  final String? initialType;

  const AddEditTransactionPage({super.key, this.transaction, this.initialType});

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Focus nodes for keyboard navigation
  final _amountFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  String _selectedType = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  List<Account> accounts = [];
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.transaction == null &&
        (widget.initialType == 'income' || widget.initialType == 'expense')) {
      _selectedType = widget.initialType!;
    }
    _loadData();
    if (widget.transaction != null) {
      _initializeWithTransaction();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _initializeWithTransaction() {
    final transaction = widget.transaction!;
    _amountController.text = transaction.amount.toString();
    _descriptionController.text = transaction.description ?? '';
    _selectedType = transaction.type;
    _selectedAccountId = transaction.accountId;
    _selectedCategoryId = transaction.categoryId;
    _selectedDate = transaction.date;
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final [accountsList, categoriesList] = await Future.wait([
        AccountService.instance.getAllAccounts(),
        CategoryService.instance.getAllCategories(),
      ]);

      setState(() {
        accounts = accountsList as List<Account>;
        categories = categoriesList as List<Category>;

        // Set default account if none selected
        if (_selectedAccountId == null && accounts.isNotEmpty) {
          _selectedAccountId = accounts.first.id;
        }

        isLoading = false;
      });

      _updateCategoriesForType();
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _updateCategoriesForType() {
    final filteredCategories =
        categories.where((cat) => cat.type == _selectedType).toList();
    if (filteredCategories.isNotEmpty &&
        (_selectedCategoryId == null ||
            !filteredCategories.any((cat) => cat.id == _selectedCategoryId))) {
      setState(() => _selectedCategoryId = filteredCategories.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // no-op: let Navigator handle back stack
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.transaction == null
              ? 'Add Transaction'
              : 'Edit Transaction'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleBackNavigation(),
          ),
          actions: widget.transaction != null
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteTransaction,
                  ),
                ]
              : null,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Transaction Type Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Type',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTypeButton(
                                    'expense',
                                    'Expense',
                                    Icons.trending_down,
                                    Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTypeButton(
                                    'income',
                                    'Income',
                                    Icons.trending_up,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Field with proper keyboard navigation
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            prefixText: '${CurrencyUtils.symbolFor()} ',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              _selectedType == 'expense'
                                  ? Icons.remove
                                  : Icons.add,
                              color: _selectedType == 'expense'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction:
                              TextInputAction.next, // Move to next field
                          onFieldSubmitted: (_) {
                            // Move focus to description field
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Field with proper keyboard navigation
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notes),
                          ),
                          textInputAction:
                              TextInputAction.done, // Last field - show done
                          onFieldSubmitted: (_) {
                            // When user presses done, attempt to save
                            _saveTransaction();
                          },
                          maxLines: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedAccountId,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance_wallet),
                              ),
                              items: accounts.map((account) {
                                return DropdownMenuItem(
                                  value: account.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: account.color != null
                                              ? Color(int.parse(account.color!
                                                  .replaceFirst('#', '0xFF')))
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(account.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedAccountId = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an account';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: categories
                                  .where((cat) => cat.type == _selectedType)
                                  .map((category) {
                                return DropdownMenuItem(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: category.color != null
                                              ? Color(int.parse(category.color!
                                                  .replaceFirst('#', '0xFF')))
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedCategoryId = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: _selectDate,
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
                                        .format(_selectedDate)),
                                    const Spacer(),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedType == 'expense'
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          widget.transaction == null
                              ? 'Add Transaction'
                              : 'Update Transaction',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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
        setState(() {
          _selectedType = type;
          _updateCategoriesForType();
        });
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _handleBackNavigation() {
    // Close keyboard if open
    FocusScope.of(context).unfocus();

    // Pop back to previous screen
    Navigator.of(context).pop();
  }

  void _saveTransaction() async {
    // Close keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate() &&
        _selectedAccountId != null &&
        _selectedCategoryId != null) {
      try {
        final transaction = Transaction(
          id: widget.transaction?.id ?? '',
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          amount: double.parse(_amountController.text),
          type: _selectedType,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          date: _selectedDate,
          createdAt: widget.transaction?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.transaction == null) {
          await TransactionService.instance.createTransaction(transaction);
        } else {
          await TransactionService.instance
              .updateTransaction(widget.transaction!, transaction);
        }

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.transaction == null
                  ? 'Transaction added successfully'
                  : 'Transaction updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Close and signal success to previous screen
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteTransaction() async {
    if (widget.transaction == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TransactionService.instance
            .deleteTransaction(widget.transaction!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: Colors.orange,
            ),
          );

          // Close and signal success to previous screen
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
