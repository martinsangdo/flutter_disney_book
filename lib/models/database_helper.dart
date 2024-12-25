import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'book_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'disney_book.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        slug TINYTEXT,
        title TEXT,
        cat TINYTEXT,
        image TEXT
      )
    ''');
  }

  Future<int> insert(Book book) async {
    Database db = await instance.db;
    return await db.insert('book', book.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.db;
    return await db.query('book');
  }

  Future<int> update(Book book) async {
    Database db = await instance.db;
    return await db.update('book', book.toMap(), where: 'slug = ?', whereArgs: [book.slug]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.db;
    return await db.delete('book', where: 'id = ?', whereArgs: [id]);
  }

}
