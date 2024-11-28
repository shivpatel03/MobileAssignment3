import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/food_item.dart';
import '../models/order_plan.dart';

class DatabaseHelper {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, 'food_order.db');
    
    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE food_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              cost REAL
            )
          ''');
          
          await db.execute('''
            CREATE TABLE order_plans (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              food_items TEXT,
              total_cost REAL
            )
          ''');

          await _insertInitialFoodItems(db);
        },
      ),
    );
  }

  Future<void> _insertInitialFoodItems(Database db) async {
    List<Map<String, dynamic>> foodItems = [
      {'name': 'Pizza', 'cost': 12.99},
      {'name': 'Burger', 'cost': 8.99},
      {'name': 'Salad', 'cost': 7.99},
      {'name': 'Pasta', 'cost': 10.99},
      {'name': 'Sushi Roll', 'cost': 15.99},
      {'name': 'Chicken Rice', 'cost': 9.99},
      {'name': 'Sandwich', 'cost': 6.99},
      {'name': 'Steak', 'cost': 24.99},
      {'name': 'Fish & Chips', 'cost': 13.99},
      {'name': 'Ramen', 'cost': 11.99},
      {'name': 'Tacos', 'cost': 8.99},
      {'name': 'Burrito', 'cost': 9.99},
      {'name': 'Pad Thai', 'cost': 12.99},
      {'name': 'Fried Rice', 'cost': 8.99},
      {'name': 'Curry', 'cost': 11.99},
      {'name': 'Noodle Soup', 'cost': 9.99},
      {'name': 'Poke Bowl', 'cost': 14.99},
      {'name': 'Greek Salad', 'cost': 8.99},
      {'name': 'Falafel Wrap', 'cost': 7.99},
      {'name': 'Beef Bowl', 'cost': 12.99},
    ];

    for (var item in foodItems) {
      await db.insert('food_items', item);
    }
  }

  Future<List<FoodItem>> getFoodItems() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food_items');
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  Future<void> addFoodItem(FoodItem item) async {
    Database db = await database;
    await db.insert('food_items', item.toMap());
  }

  Future<void> updateFoodItem(FoodItem item) async {
    Database db = await database;
    await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteFoodItem(int id) async {
    Database db = await database;
    await db.delete('food_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveOrderPlan(OrderPlan orderPlan) async {
    Database db = await database;
    await db.insert('order_plans', orderPlan.toMap());
  }

  Future<OrderPlan?> getOrderPlanByDate(String date) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (results.isNotEmpty) {
      return OrderPlan.fromMap(results.first);
    }
    return null;
  }
}
