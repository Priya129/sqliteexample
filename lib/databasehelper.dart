import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertItem(
      String title, String description, String imagePath) async {
    final db = await database;
    return await db.insert('items',
        {'title': title, 'description': description, 'imagePath': imagePath});
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items');
  }

  Future<int> updateItems(
      int id, String title, String description, String imagePath) async {
    final db = await database;
    return await db.update(
        'items',
        {
          'title': title,
          'description': description,
          'imagePath': imagePath,
        },
        where: 'id=?',
        whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id =?', whereArgs: [id]);
  }
}
