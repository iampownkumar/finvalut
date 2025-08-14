import 'package:flutter/material.dart';
import 'package:finvault/core/models/category.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final String? initialType;
  final Function(Category) onSave;

  const AddEditCategoryDialog({
    super.key,
    this.category,
    this.initialType,
    required this.onSave,
  });

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedIcon = 'category';
  String _selectedColor = '#EF4444';

  final List<Map<String, dynamic>> _icons = [
    {'value': 'restaurant', 'icon': Icons.restaurant, 'label': 'Food'},
    {
      'value': 'directions_car',
      'icon': Icons.directions_car,
      'label': 'Transport'
    },
    {'value': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'value': 'home', 'icon': Icons.home, 'label': 'Home'},
    {'value': 'health', 'icon': Icons.local_hospital, 'label': 'Health'},
    {'value': 'education', 'icon': Icons.school, 'label': 'Education'},
    {'value': 'movie', 'icon': Icons.movie, 'label': 'Entertainment'},
    {'value': 'travel', 'icon': Icons.flight, 'label': 'Travel'},
    {'value': 'work', 'icon': Icons.work, 'label': 'Work'},
    {'value': 'gift', 'icon': Icons.card_giftcard, 'label': 'Gifts'},
    {'value': 'category', 'icon': Icons.category, 'label': 'Other'},
  ];

  final List<String> _expenseColors = [
    '#EF4444',
    '#F97316',
    '#F59E0B',
    '#EAB308',
    '#84CC16',
    '#22C55E',
    '#10B981',
    '#14B8A6',
    '#06B6D4',
    '#0EA5E9',
    '#3B82F6',
    '#6366F1',
    '#8B5CF6',
    '#A855F7',
    '#D946EF',
  ];

  final List<String> _incomeColors = [
    '#22C55E',
    '#10B981',
    '#14B8A6',
    '#059669',
    '#047857',
    '#065F46',
    '#84CC16',
    '#65A30D',
    '#166534',
    '#15803D',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon ?? 'category';
      _selectedColor = widget.category!.color ??
          (_selectedType == 'expense' ? '#EF4444' : '#22C55E');
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
      _selectedColor = _selectedType == 'expense' ? '#EF4444' : '#22C55E';
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
                  widget.category == null ? 'Add Category' : 'Edit Category',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Category Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type Selection
                Text(
                  'Type',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton('expense', 'Expense', Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeButton('income', 'Income', Colors.green),
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
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final iconData = _icons[index];
                      final isSelected = _selectedIcon == iconData['value'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIcon = iconData['value']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : null,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                iconData['icon'],
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                iconData['label'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
                  children: (_selectedType == 'expense'
                          ? _expenseColors
                          : _incomeColors)
                      .map((colorHex) {
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
                      onPressed: _saveCategory,
                      child: Text(widget.category == null ? 'Add' : 'Save'),
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

  Widget _buildTypeButton(String type, String label, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // Update color based on type
          _selectedColor = type == 'expense' ? '#EF4444' : '#22C55E';
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = Category(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        type: _selectedType,
        icon: _selectedIcon,
        color: _selectedColor,
        isActive: true,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(category);
      Navigator.pop(context);
    }
  }
}
