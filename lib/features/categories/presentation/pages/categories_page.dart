import 'package:flutter/material.dart';
import 'package:finvault/core/models/category.dart';
import 'package:finvault/core/services/category_service.dart';
import 'package:finvault/features/categories/presentation/widgets/category_card.dart';
import 'package:finvault/features/categories/presentation/widgets/add_edit_category_dialog.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final allCategories = await CategoryService.instance.getAllCategories();
      setState(() {
        _expenseCategories =
            allCategories.where((c) => c.type == 'expense').toList();
        _incomeCategories =
            allCategories.where((c) => c.type == 'income').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryGrid(_expenseCategories, 'expense'),
                _buildCategoryGrid(_incomeCategories, 'income'),
              ],
            ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return _buildEmptyState(type);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(
          category: categories[index],
          onTap: () => _viewCategoryDetails(categories[index]),
          onEdit: () => _showEditCategoryDialog(categories[index]),
          onDelete: () => _deleteCategory(categories[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type} categories yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first ${type} category',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(type),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog([String? type]) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        initialType: type ?? (_tabController.index == 0 ? 'expense' : 'income'),
        onSave: (category) async {
          await CategoryService.instance.createCategory(category);
          _loadCategories();
        },
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        category: category,
        onSave: (updatedCategory) async {
          await CategoryService.instance.updateCategory(updatedCategory);
          _loadCategories();
        },
      ),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await CategoryService.instance.deleteCategory(category.id);
              _loadCategories();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${category.name} deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewCategoryDetails(Category category) {
    // TODO: Navigate to category details/transactions page in Phase 3
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Category details for ${category.name} - Coming in Phase 3!')),
    );
  }
}
