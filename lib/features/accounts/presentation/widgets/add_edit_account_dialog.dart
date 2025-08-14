import 'package:flutter/material.dart';
import 'package:finvault/core/models/account.dart';

class AddEditAccountDialog extends StatefulWidget {
  final Account? account;
  final Function(Account) onSave;

  const AddEditAccountDialog({
    super.key,
    this.account,
    required this.onSave,
  });

  @override
  State<AddEditAccountDialog> createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends State<AddEditAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedType = 'bank';
  String _selectedCurrency = 'INR';
  String _selectedIcon = 'bank';
  String _selectedColor = '#6366F1';

  final List<Map<String, dynamic>> _accountTypes = [
    {'value': 'bank', 'label': 'Bank Account', 'icon': Icons.account_balance},
    {'value': 'cash', 'label': 'Cash', 'icon': Icons.money},
    {'value': 'card', 'label': 'Card', 'icon': Icons.credit_card},
    {'value': 'savings', 'label': 'Savings', 'icon': Icons.savings},
  ];

  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP'];

  final List<Map<String, dynamic>> _icons = [
    {'value': 'bank', 'icon': Icons.account_balance},
    {'value': 'wallet', 'icon': Icons.account_balance_wallet},
    {'value': 'card', 'icon': Icons.credit_card},
    {'value': 'cash', 'icon': Icons.money},
    {'value': 'savings', 'icon': Icons.savings},
  ];

  final List<String> _colors = [
    '#6366F1',
    '#10B981',
    '#EF4444',
    '#F59E0B',
    '#8B5CF6',
    '#06B6D4',
    '#84CC16',
    '#F97316',
    '#EC4899',
    '#6B7280'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _selectedType = widget.account!.type;
      _selectedCurrency = widget.account!.currency;
      _selectedIcon = widget.account!.icon ?? 'bank';
      _selectedColor = widget.account!.color ?? '#6366F1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.account == null ? 'Add Account' : 'Edit Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Account Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Account Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _accountTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'] as String,
                      child: Row(
                        children: [
                          Icon(type['icon'], size: 20),
                          const SizedBox(width: 8),
                          Text(type['label']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      // Auto-select appropriate icon
                      _selectedIcon = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Currency & Initial Balance
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        items: _currencies.map((currency) {
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCurrency = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                          labelText: 'Initial Balance',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter initial balance';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon Selection
                Text(
                  'Icon',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _icons.map((iconData) {
                    final isSelected = _selectedIcon == iconData['value'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIcon = iconData['value']),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData['icon'],
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color Selection
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _colors.map((colorHex) {
                    final color =
                        Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                    final isSelected = _selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorHex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 4)
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
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
                      onPressed: _saveAccount,
                      child: Text(widget.account == null ? 'Add' : 'Save'),
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

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.account?.id ?? '',
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        balance: double.parse(_balanceController.text),
        icon: _selectedIcon,
        color: _selectedColor,
        isActive: true,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(account);
      Navigator.pop(context);
    }
  }
}
