import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'fridgematch.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS meals');
    await db.execute('DROP TABLE IF EXISTS ingredients');
    await _createTables(db);
    await _seedData(db);
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS meals(id INTEGER PRIMARY KEY, data TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS ingredients(id TEXT PRIMARY KEY, data TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS favorites(id INTEGER PRIMARY KEY AUTOINCREMENT, meal_id INTEGER UNIQUE)');
    await db.execute('CREATE TABLE IF NOT EXISTS shopping(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, bought INTEGER DEFAULT 0)');
  }

  static Future<void> _seedData(Database db) async {
    try {
      final mealsJson = await rootBundle.loadString('assets/meals.json');
      final ingredientsJson = await rootBundle.loadString('assets/ingredients.json');
      final List meals = jsonDecode(mealsJson);
      final List ingredients = jsonDecode(ingredientsJson);

      await db.transaction((txn) async {
        for (final m in meals) {
          await txn.insert('meals', {'id': m['id'], 'data': jsonEncode(m)},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        for (final i in ingredients) {
          await txn.insert('ingredients', {'id': i['id'].toString(), 'data': jsonEncode(i)},
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } catch (e, stack) {
      debugPrint('SEEDING ERROR: $e');
      debugPrint('SEEDING STACK: $stack');
    }
  }

  static Future<List<Map<String, dynamic>>> getMeals() async {
    final db = await database;
    final rows = await db.query('meals');
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getIngredients() async {
    final db = await database;
    final rows = await db.query('ingredients');
    return rows.map((r) => jsonDecode(r['data'] as String) as Map<String, dynamic>).toList();
  }

  static Future<void> toggleFavorite(int mealId) async {
    final db = await database;
    final existing = await db.query('favorites', where: 'meal_id = ?', whereArgs: [mealId]);
    if (existing.isEmpty) {
      await db.insert('favorites', {'meal_id': mealId},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      await db.delete('favorites', where: 'meal_id = ?', whereArgs: [mealId]);
    }
  }

  static Future<bool> isFavorite(int mealId) async {
    final db = await database;
    final r = await db.query('favorites', where: 'meal_id = ?', whereArgs: [mealId]);
    return r.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getFavoriteMeals() async {
    final db = await database;
    final favs = await db.query('favorites');
    final mealIds = favs.map((f) => f['meal_id']).toList();
    if (mealIds.isEmpty) return [];
    final meals = await getMeals();
    return meals.where((m) => mealIds.contains(m['id'])).toList();
  }

  static Future<void> addShoppingItem(String name) async {
    final db = await database;
    await db.insert('shopping', {'name': name, 'bought': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getShoppingItems() async {
    final db = await database;
    return db.query('shopping', orderBy: 'id ASC');
  }

  static Future<void> toggleShoppingBought(int id, int current) async {
    final db = await database;
    await db.update('shopping', {'bought': current == 0 ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteShoppingItem(int id) async {
    final db = await database;
    await db.delete('shopping', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearShoppingList() async {
    final db = await database;
    await db.delete('shopping');
  }
}