import 'package:finvault/core/database/database_helper.dart';
import 'package:finvault/core/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryService {
  static final CategoryService instance = CategoryService._init();
  CategoryService._init();

  final _uuid = const Uuid();

  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'type, name',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'isActive = ? AND type = ?',
      whereArgs: [1, type],
      orderBy: 'name',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<String> createCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final categoryWithId = Category(
      id: id,
      name: category.name,
      type: category.type,
      icon: category.icon,
      color: category.color,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('categories', categoryWithId.toMap());
    return id;
  }

  Future<void> updateCategory(Category category) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'categories',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
